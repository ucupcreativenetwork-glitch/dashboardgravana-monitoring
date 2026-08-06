# Ansible — multi-node node_exporter

```bash
cp inventory.ini.example inventory.ini
ansible-playbook -i inventory.ini playbook-node-exporter.yml
```

Then add hosts to `prometheus/targets/nodes.json` on the monitoring server.
