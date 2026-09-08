# Module 5 — Adding a Compute Layer Using Amazon EC2

**Status:** not started | **Confidence:** –

## Scope
Launching and configuring instances, storage, and instance-level security.
**High-marks module — expect hands-on tasks.**

## Key concepts to know cold
- **AMI:** the template (OS + config). Region-scoped; copy it to use elsewhere.
- **Instance families:** general purpose (t, m), compute optimized (c),
  memory optimized (r, x), storage optimized (i, d), accelerated (p, g).
- **Purchasing options:** On-Demand (no commitment) · Reserved Instances /
  Savings Plans (1 or 3 yr commitment, big discount) · **Spot** (up to ~90% off,
  can be interrupted with 2-min warning — use for fault-tolerant/batch) ·
  Dedicated Hosts/Instances (compliance, licensing).
- **User data:** shell script run **once at first boot** — used to install and
  configure software automatically. Starts with `#!/bin/bash`, runs as root.
- **Instance metadata:** `http://169.254.169.254/latest/meta-data/` — how an
  instance learns its own instance-id, IP, and retrieves role credentials.
- **EBS:** network-attached persistent block storage, **AZ-scoped**.
  gp3/gp2 (general SSD), io1/io2 (provisioned IOPS), st1/sc1 (throughput HDD).
  Snapshots are stored in S3, incremental, and are how you move a volume to
  another AZ or Region.
- **Instance store:** physically attached, very fast, **ephemeral** — data is
  lost on stop/terminate.
- **Security groups:** instance-level, **stateful** (return traffic auto-allowed),
  **allow rules only**, default = deny all inbound / allow all outbound.
- **Key pairs:** you keep the private key. AWS cannot recover it for you.
- **IAM role / instance profile:** the correct way to give an instance
  permissions — never put access keys in user data or on disk.

## Typical AWS Academy lab
Building the café's **dynamic website**: launch an EC2 instance with a user
data script that installs a LAMP stack and the café application, attach a
security group allowing HTTP, then reach the site by public IP/DNS.

## High-yield gotchas (marks lost here)
- **Stop → start changes the public IPv4 address** (unless an Elastic IP is
  attached). The private IP does not change.
- User data runs **only on the first boot** by default — re-running it after a
  change means either re-launching or running the script manually.
- Can't SSH/HTTP in? Check in this order: security group inbound rule →
  subnet route table has a route to the IGW → instance has a public IP →
  NACL → OS firewall.
- EBS volumes attach only to instances **in the same AZ**. Cross-AZ move =
  snapshot → create volume in target AZ.
- Security groups cannot **deny**. If you need an explicit deny, that's a NACL.
- Best practice: reference **another security group** as the source (e.g. web SG
  as source in the DB SG) instead of hardcoding a CIDR.

## Self-check questions
1. Write a user data script that installs Apache and starts it on Amazon Linux.
2. Instance stopped and started, and your bookmark now 404s. Why?
3. Where do you attach permissions so an app on EC2 can read an S3 bucket?
4. Spot vs On-Demand vs Reserved — give one workload for each.

## My notes
_(fill in as we go)_

---

## Amazon EFS (Elastic File System) — also Module 5, so IN TEST SCOPE
The Module 5 lab "Introducing Amazon EFS" confirms EFS is examinable here.

| | **EBS** | **EFS** | **Instance store** |
|---|---|---|---|
| Type | block | **file (NFS)** | block |
| Attach | **one instance** (usually), **one AZ** | **many instances, across AZs** | one instance |
| Scope | AZ | **Regional** | the host |
| Persists? | yes | yes | **NO — lost on stop/terminate** |
| Scaling | fixed size you provision | **grows/shrinks automatically** | fixed |

- **EFS is a shared filesystem**: many EC2 instances mount it at once and see the
  same files. That is the thing EBS cannot do.
- Linux only (NFS v4). The Windows equivalent is **FSx for Windows File Server**.
- Mounted with an NFS client at a **mount target** in each AZ.
- Storage classes: Standard and **Infrequent Access (EFS-IA)**, with lifecycle
  management to move cold files automatically.

**Choosing, for an exam scenario:**
- "Shared files across many instances / a shared content directory" → **EFS**
- "A single instance's disk / boot volume / database storage" → **EBS**
- "Temporary scratch, maximum speed, data loss acceptable" → **instance store**
- "Objects over HTTP, static website, unlimited scale" → **S3**

## EFS — build path for a practical task
```
EFS → Create file system
   Name: <name>
   VPC:  <the lab VPC>
   [Customize] for: Storage class (Standard | One Zone),
                    lifecycle policy to IA,
                    encryption at rest,
                    performance / throughput mode
   → Create
```
Then **Network tab → mount targets**: one per AZ, each with a **security group**.

Mount it on an EC2 instance:
```bash
sudo yum install -y amazon-efs-utils
sudo mkdir -p /mnt/efs
sudo mount -t efs -o tls fs-xxxxxxxx:/ /mnt/efs
df -h            # confirm it is mounted
```

### The detail most likely to be marked
**The mount target's security group must allow inbound NFS (TCP 2049) from the
EC2 instances' security group.** This is the same security-group-chaining
pattern as the three-tier build: source = a security group, not a CIDR. Without
it the mount hangs and eventually times out (a routing/permission symptom, not
"connection refused").

Second most likely: **a mount target in every AZ** where instances run — that is
what makes EFS highly available, and matches the "two AZs" rule.

### Quick decisions a brief might ask for
- **Standard vs One Zone** — One Zone is cheaper but lives in a single AZ, so it
  is not highly available.
- **Lifecycle policy** — move files not accessed for N days to **EFS-IA** to cut cost.
- **Encryption at rest** — must be chosen **at creation** (same rule as EBS and RDS).

---

## EFS — built and verified end to end (2026-09-08)

### Build order
1. **Security group first** — `efs-sg`, inbound **NFS 2049 from the EC2 instances'
   security group** (`app-sg`). *This rule is the graded line in every EFS task.*
2. **EFS → Create file system → Customize** (not the quick create).
   - Network access step: a **mount target per AZ**, in the **private subnets**
     where the instances live, each with **`efs-sg`** (remove `default`).
   - A mount target must be in the **same AZ** as the instance mounting it.
3. Wait for both mount targets **Available**.

### Mount (the lecturer's version, which is the robust one)
```bash
sudo yum -y install amazon-efs-utils
sudo yum -y install python3-botocore      # DO NOT SKIP — see below
sudo mkdir -p /mnt/efs
sudo mount -t efs -o tls fs-XXXXXXXX:/ /mnt/efs
df -h /mnt/efs                            # ALWAYS verify
```
Persistent across reboot:
`echo "fs-XXXX:/ /mnt/efs efs _netdev,tls 0 0" | sudo tee -a /etc/fstab`

### What actually went wrong (both real, both cost time)
- **Wrong file system ID.** `Failed to resolve "fs-….efs.us-east-1.amazonaws.com"`.
  The error's FIRST clause said *"check that your file system ID is correct"* — and
  it was right. **Read the first clause of an error, not the last.**
- **`python3-botocore` missing.** Without it the EFS helper cannot fall back to
  looking up the mount target IP via the API when DNS is unhelpful. Installing it
  is what finally made the mount succeed.
- VPC needs **both** *Enable DNS resolution* **and** *Enable DNS hostnames* for the
  EFS DNS name to resolve.

### TRAP: a failed mount looks like success
`mount` failing leaves `/mnt/efs` as an ordinary **local folder**. Writing to it
appears to work, and the other instance sees nothing. **Always `df -h /mnt/efs`
after mounting** — you want a line for the file system showing **8.0E**.

### Reading the verified output
- `127.0.0.1:/` as the filesystem = correct when using `-o tls`; the mount goes via
  local **stunnel**, which encrypts and forwards to the mount target. Without
  `tls` you see the mount target IP (e.g. `10.0.2.37:/`).
- **8.0E** = EFS reporting effectively unlimited. EFS grows/shrinks automatically;
  you never provision a size. Contrast EBS: fixed size, chosen up front, paid for
  whether used or not.

### Failure → cause
| Symptom | Cause |
|---|---|
| `Failed to resolve fs-…` | Wrong file system ID; or VPC DNS resolution/hostnames off |
| Mount **hangs** | `efs-sg` missing NFS 2049 from the instances' SG |
| `mount point /mnt/efs does not exist` | `mkdir -p /mnt/efs` not run on that instance |
| Mounts but other instance sees nothing | The mount silently failed — check `df -h` |

### Teardown
`sudo umount /mnt/efs` on each instance → **EFS → Delete** (removes mount targets)
→ delete `efs-sg`.
