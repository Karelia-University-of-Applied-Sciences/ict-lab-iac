# Task3: PKI + HTTPS Load Balancer

Demonstrates a full PKI trust chain using Terraform and Ansible on Nutanix:
a Root CA signs certificates for all VMs, an nginx load balancer terminates HTTPS
from clients and proxies traffic to HTTPS-only web backends.

## Architecture

### LB
```mermaid
graph TD
    Client -->|HTTPS 443| LB

    CA[VM 1 · Root CA<br>ca.yml]
    LB[VM 2 · Load Balancer - nginx<br>lb.yml]
    W1[VM 3 · web1 - nginx<br>web.yml]
    W2[VM 4 · web2 - nginx<br>web.yml]

    LB -->|HTTPS 443 round-robin| W1
    LB -->|HTTPS 443 round-robin| W2
```

### PKI
```mermaid
graph LR
    CA[VM 1 · Root CA]
    LB[VM 2 · Load Balancer - nginx]
    W1[VM 3 · web1 - nginx]
    W2[VM 4 · web2 - nginx]

    CA -->|signs cert| LB
    CA -->|signs cert| W1
    CA -->|signs cert| W2
```

| VM | Role | Ansible Group |
|----|------|---------------|
| `*-ca` | Root CA — signs all CSRs | `task3_ca` |
| `*-lb` | nginx load balancer — HTTPS round-robin | `task3_lb` |
| `*-web1`, `*-web2`, … | nginx web servers — unique HTTPS pages | `task3_web` |

## Ansible playbooks workflow
### PKI
```mermaid
flowchart TD
    subgraph CA["VM 1 · Root CA  (ca.yml)"]
        CA_KEY["Generate RSA 4096 key"]
        CA_CSR_N["Generate CA CSR<br>CA:TRUE · keyCertSign"]
        CA_CERT["Self-sign certificate<br>+3650 days  (ca.crt)"]
        CA_HTTP["nginx serves ca.crt<br>over HTTP :80"]
        CA_SIGN["Sign host CSR<br>with ownca · +365 days"]

        CA_KEY --> CA_CSR_N --> CA_CERT --> CA_HTTP
    end

    CTL(["Ansible Controller<br>/tmp/task3/"])

    subgraph LB["VM 2 · Load Balancer  (lb.yml)"]
        LB_KEY["Generate RSA 2048 key"]
        LB_CSR["Generate CSR<br>SAN: DNS + IP"]
        LB_DEPLOY["nginx HTTPS :443<br>host.crt + ca.crt"]

        LB_KEY --> LB_CSR
    end

    subgraph WEB["VM 3/4 · Web Servers  (web.yml)"]
        W_KEY["Generate RSA 2048 key"]
        W_CSR["Generate CSR<br>SAN: DNS + IP"]
        W_DEPLOY["nginx HTTPS :443<br>host.crt + ca.crt"]

        W_KEY --> W_CSR
    end

    CA_CERT -->|"fetch ca.crt"| CTL
    LB_CSR -->|"fetch CSR"| CTL
    W_CSR  -->|"fetch CSR"| CTL
    CTL    -->|"copy CSR to CA"| CA_SIGN
    CA_SIGN -->|"fetch signed cert"| CTL
    CTL -->|"copy cert + ca.crt"| LB_DEPLOY
    CTL -->|"copy cert + ca.crt"| W_DEPLOY
```

### Web server configuration
```mermaid
flowchart LR
    subgraph WEB["VM 3/4 · Web Servers  (web.yml)"]
        direction TB
        W_CONF["Deploy nginx-web.conf.j2<br>listen 443 ssl"]
        W_IDX["Deploy unique index.html<br>per-host backend page"]
        W_UP["nginx HTTPS :443 active"]

        W_CONF --> W_IDX --> W_UP    
    end

    CTL(["Ansible Controller"])

    subgraph LB["VM 2 · Load Balancer  (lb.yml)"]
        direction TB
        LB_HOSTS["/etc/hosts populated"]
        LB_CONF["nginx-lb.conf.j2 rendered"]
        LB_UP["nginx HTTPS :443 active<br>round-robin proxy to upstream"]

        LB_HOSTS --> LB_CONF --> LB_UP
    end

    LB <--> |"render upstream<br>block"| CTL
    CTL --> |"hostnames<br>IPs"| WEB
```

### Certificate renewal (renew.yml)
```mermaid
flowchart TD
    CHECK["Check cert expiry<br>x509_certificate_info"]
    DECISION{{"needs_renewal?<br>expiry &lt; 30 days<br>OR force_renew=true<br>OR cert missing"}}
    SKIP["Skip — cert still valid"]

    CHECK --> DECISION
    DECISION -->|no| SKIP
    DECISION -->|yes| RM

    subgraph CA["VM 1 · Root CA"]
        RM["Remove old staged cert<br>so CA re-signs"]
        SIGN["Sign CSR with ownca<br>+365 days"]
        RM --> SIGN
    end

    subgraph HOST["VM 2/3/4 · LB + Web Servers"]
        CSR["Existing CSR<br>(key unchanged)"]
        DEPLOY["Deploy renewed cert"]
        RELOAD["Reload nginx"]
        DEPLOY --> RELOAD
    end

    CTL(["Ansible Controller"])

    DECISION -->|yes| CSR
    CSR -->|"fetch CSR"| CTL
    CTL -->|"copy CSR to CA"| RM
    SIGN -->|"fetch signed cert"| CTL
    CTL -->|"copy cert"| DEPLOY
```

## Scaling the web tier

To add more web servers, edit `infra.auto.tfvars`:

```hcl
web_server_names = ["web1", "web2", "web3"]
```

Then re-provision and reconfigure:

```bash
terraform apply
ansible-playbook site.yml
```

The new VM is automatically included in the LB upstream block and receives its own CA-signed certificate.

## How to run

### 1. Provision VMs with Terraform

```bash
cd implementation/task3/terraform
tofu init
tofu apply
```

### 2. Install Ansible collections

```bash
cd implementation/task3/ansible
ansible-galaxy collection install -r requirements.yml
```

### 3. Verify connectivity

```bash
ansible -m ping all
```

### 4. Deploy the full stack

```bash
ansible-playbook playbooks/site.yml
```

All playbooks are fully idempotent — re-running them is safe. `community.crypto` modules only regenerate keys and certificates if they don't already exist or have changed.

Or run individual playbooks:

```bash
ansible-playbook playbooks/ca.yml     # Set up Root CA
ansible-playbook playbooks/web.yml    # Configure web servers (requires CA to be ready)
ansible-playbook playbooks/lb.yml     # Configure load balancer (requires CA to be ready)
ansible-playbook playbooks/renew.yml  # Renew certs expiring within 30 days
```

## Verification

```bash
# Download the CA certificate from the CA VM (served over HTTP by nginx)
curl http://<CA_IP>/ca.crt -o ca.crt

# Hit the LB with full certificate validation
curl --cacert ca.crt https://<LB_IP>/

# Verify a web server's certificate against the CA
openssl verify -CAfile ca.crt /tmp/task3/<web-vm-hostname>.crt
```

To trust the CA in your browser or OS, import `ca.crt` into your trust store:

```bash
# Linux (system-wide)
sudo cp ca.crt /usr/local/share/ca-certificates/task3-ca.crt
sudo update-ca-certificates
```

## Certificate flow

```
CA VM                     Controller             Web / LB VM
 │                            │                      │
 │                            │  Generate key+CSR    │
 │                            │◄─────────────────────│
 │  Copy CSR to CA            │                      │
 │◄───────────────────────────│                      │
 │  Sign CSR (ownca)          │                      │
 │─────────────────────────►  │                      │
 │  Fetch signed cert         │                      │
 │──────────────────────────► │                      │
 │                            │  Deploy cert + CA cert│
 │                            │──────────────────────►│
```

The CA private key (`/etc/pki/ca/ca.key`) never leaves VM 1.
