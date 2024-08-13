
```markdown

# Celestia Node Deployment

## Overview

This Ansible playbook automates the setup and deployment of a Celestia Node using Docker. It handles creating directories, initializing the node store, and starting the node.

## Prerequisites

- Make sure you're using a group named `celestia` to use the `celestia.yaml` configuration in `group_vars`.

## Variables

- `node_type`: Type of Celestia node (e.g., `light`).
- `p2p_network`: P2P network for the node (e.g., `Mocha`).
- `rpc_url`: RPC endpoint URL.
- `celestia_home`: Path to Celestia home directory.

## Steps

1. **Create Directory for Node Store**:
   Creates a directory on the host machine to store node data.

2. **Initialize Celestia Node Store**:
   Initializes the Celestia node store using Docker with the provided environment variables.

3. **Start Celestia Node**:
   Starts the Celestia node with the specified command and environment settings.

Ensure you have the correct Docker image and necessary variables set before running the playbook.

# Celestia App Deployment

## Overview

This Ansible playbook automates the setup and deployment of a Celestia App using Docker. It performs initialization, downloads the genesis file, and starts the Celestia App container.

## Prerequisites

- Create a group named `celestia` to use the `celestia.yaml` configuration in `group_vars`.

## Variables

- `celestia_app_image`: Docker image for Celestia.
- `node_name`: Celestia node name.
- `chain_id`: Chain ID for the network.
- `rpc_port`, `p2p_port`, `grpc_port`: Ports for RPC, P2P, and gRPC services.

## Steps

1. **Initialize Celestia App**: 
   Initializes the Celestia node.

2. **Download Genesis File**:
   Fetches the genesis file required for node operation.

3. **Run Celestia App**:
   Starts the Celestia application.

## Playbooks Overview

### `deploy_celestia_stack.yml`
- **Actions**:
  - Install dependencies.
  - Deploy Celestia Node.
  - Deploy Celestia App.

### `deploy_celestia_node.yml`
- **Actions**:
  - Install dependencies.
  - Deploy Celestia Node only.