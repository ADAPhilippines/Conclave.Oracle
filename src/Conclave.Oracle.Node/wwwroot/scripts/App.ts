import { ethers, Wallet, providers, UnsignedTransaction, Contract, BigNumber, PopulatedTransaction } from 'ethers';

window.abi = [
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "requestId",
				"type": "uint256"
			}
		],
		"name": "addPendingRequests",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bool",
				"name": "_result",
				"type": "bool"
			}
		],
		"name": "changeIsDelegatorResult",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "requestId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"name": "request",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "requestId",
				"type": "uint256"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"name": "RequestCreated",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "num",
				"type": "uint256"
			}
		],
		"name": "store",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "requestId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "decimals",
				"type": "uint256"
			}
		],
		"name": "submitResult",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getPendingRequests",
		"outputs": [
			{
				"internalType": "uint256[]",
				"name": "",
				"type": "uint256[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "isDelegated",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "retrieve",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "submitted",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
];

window.InitializeEthWallet = (privateKey : string) : Wallet | undefined =>
{
    try {     
        return new Wallet(privateKey, new providers.JsonRpcProvider("https://rpc-devnet-cardano-evm.c1.milkomeda.com"));  
      } catch (err) {
        console.log(err);
      }
}

window.GetPublicAddress = async (privateKey: string) : Promise<string> => {
	return await (new Wallet(privateKey, new providers.JsonRpcProvider("https://rpc-devnet-cardano-evm.c1.milkomeda.com"))).getAddress();
}

window.GetBlockHashFromSlotAsync = async (slotNumber : number) : Promise<BigInt> =>
{
	let res : string = "";
    await fetch('https://cardano-preview.blockfrost.io/api/v0/blocks/slot/1240682', 
	{
        headers: {"project_id": "previewZykJ25mbqLINiYgLJc4zAzYE6eJdduBI"}
    }).then(response => response.json()) 
    .then(json => {
		res = json.hash;
		console.log(json.hash);
	}); 
	return BigInt(parseInt(res, 16));
}

//Done
window.IsDelegatedAsync = async (privateKey: string, contractAddress: string) : Promise<boolean> => {
    const contract : Contract = new ethers.Contract(contractAddress, window.abi, window.InitializeEthWallet(privateKey));
    return await contract.isDelegated();
}

window.GetPendingRequestsAsync = async (privateKey: string, contractAddress: string) : Promise<BigNumber[]> => {
    const contract : Contract = new ethers.Contract(contractAddress, window.abi, window.InitializeEthWallet(privateKey));
	return await contract.getPendingRequests(); 
}

window.SubmitResultAsync = async (privateKey: string, contractAddress: string, requestId: string, decimals: string) : Promise<void> => {
    const wallet : Wallet = window.InitializeEthWallet(privateKey);
    const contract : Contract = new ethers.Contract(contractAddress, window.abi, wallet);

    let gasPriceHex : string = ethers.utils.hexlify(80000000000000);
    let gasLimitHex : string = ethers.utils.hexlify(4000000);

    let unsignedTx  : PopulatedTransaction = await contract.populateTransaction.submitResult(BigNumber.from(requestId), BigNumber.from(decimals));
    unsignedTx.gasLimit = BigNumber.from(gasLimitHex);
    unsignedTx.gasPrice = BigNumber.from(gasPriceHex);

    await wallet.sendTransaction(unsignedTx);
}

window.ListenToRequestCreatedEventAsync = async (contractAddress: string) => {
  const contract : Contract = new Contract(contractAddress, window.abi, new providers.WebSocketProvider(`wss://rpc-devnet-cardano-evm.c1.milkomeda.com`));
  contract.on("RequestCreated", (requestId : BigNumber, sender : string, timestamp : BigNumber) => {
	console.log(requestId);
	console.log(timestamp);
    // Do something
	window.requestnumbers(requestId.toString(), timestamp.toString());
  });
}