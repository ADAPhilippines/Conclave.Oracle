export { }
declare global {
    interface Window {
        timestampNow: () => number;
        csharp: () => void;
    }
}