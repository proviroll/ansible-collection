### reffer to https://docs.celestia.org/nodes/docker-images
# > Quick start
# Set the network you would like to run your node on:
 Mainnet Beta
 Mocha
 Arabica
# bash
# export 
`NETWORK=celestia`
# Set the node type
`Light`
# export 
`NODE_TYPE=light`
# Set an RPC endpoint for either Mainnet Beta, Mocha, or Arabica using the bare URL (without http or https):
# export `RPC_URL=this-is-an-rpc-url.com`
# Run the image from the command line:
`docker run -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \`
`ghcr.io/celestiaorg/celestia-node:v0.13.7 \`
`celestia $NODE_TYPE start --core.ip $RPC_URL --p2p.network $NETWORK`