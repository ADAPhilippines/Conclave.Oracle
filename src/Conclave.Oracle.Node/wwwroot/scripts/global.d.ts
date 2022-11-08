export { }
declare global {
    interface Window {
        csharp: () => void;
        ListenToContractEventAsync: (contractAddress: string, eventName: string) => Promise<void>;
        InitializeEthWallet: (privateKey : string) => Wallet;
        GetSlotFromUnixTimeMilliSeconds: (unixTime: string) => Promise<string>;
        abi: object[];
        IsDelegatedAsync: (privateKey: string, contractAddress: string) => Promise<boolean>;
        GetBlockHashFromSlotAsync: (slotNumber : number) => Promise<BigInt>;
        GetPendingRequestsAsync: (privateKey: string, contractAddress: string) => Promise<string[]>;
        SubmitResultAsync: (privateKey: string, contractAddress: string, requestId: string, decimals: BigNumber[]) => Promise<void>;
        ListenToContractEventAsync: (privateKey: string, contractAddress: string, eventName: string) => void;
    }
}