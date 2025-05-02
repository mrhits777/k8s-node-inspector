
# 🔍 k8s-node-inspector

A battle-tested, enterprise-grade Kubernetes node audit script written in Bash.  
Designed by an SRE for SREs — fast, portable, and zero-dependency beyond `kubectl` and `jq`.

---

## 🚀 What It Does

`k8s-node-inspector.sh` inspects every node in your Kubernetes cluster and reports:

- ✅ Node metadata (OS, kernel, runtime)
- 🚫 Taints (e.g. NoSchedule, PreferNoSchedule)
- 🔥 Node conditions (e.g. MemoryPressure, DiskPressure)
- ⚖️ Resource pressure (allocatable vs actual usage)
- 🧠 Pod distribution per node
- 📜 Saves all output to a timestamped `.log` file

Ideal for:

- Pre-deployment health checks  
- Infrastructure drift detection  
- Post-incident node diagnostics  
- Routine audits and documentation

---

## 📦 Requirements

- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [jq](https://stedolan.github.io/jq/)

---

## 🧪 How to Run

```bash
git clone https://github.com/mrhits777/k8s-node-inspector.git
cd k8s-node-inspector
chmod +x k8s-node-inspector.sh
./k8s-node-inspector.sh
