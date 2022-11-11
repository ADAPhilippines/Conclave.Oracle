export { }
declare global {
    interface Window {
        csharp: () => void;
        ListenToRequestCreatedEventAsync: (contractAddress: string) => Promise<void>;
        InitializeEthWallet: (privateKey : string) => Wallet;
        GetSlotFromUnixTimeMilliSeconds: (unixTime: string) => Promise<string>;
        abi: object[];
        IsDelegatedAsync: (privateKey: string, contractAddress: string) => Promise<boolean>;
        GetBlockHashFromSlotAsync: (slotNumber : number) => Promise<BigInt>;
        GetPendingRequestsAsync: (privateKey: string, contractAddress: string) => Promise<BigNumber[]>;
        SubmitResultAsync: (privateKey: string, contractAddress: string, requestId: string, decimals: string) => Promise<void>;
        ListenToContractEventAsync: (privateKey: string, contractAddress: string, eventName: string) => void;
        requestnumbers: (requestId: string, timestamp: string) => RequestModel;
        GetPublicAddress: (privateKey: string) => Promise<string>;
    }
}

declare global {
    type RequestModel = {
        requestId: number;
        timeslot: number;
    }
}