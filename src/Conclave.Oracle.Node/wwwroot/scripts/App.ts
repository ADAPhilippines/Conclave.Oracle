import moment from "moment";

window.timestampNow = () => {
    return moment.now();
}

window.onload = () => {
    setTimeout(() => {
        window.csharp();
    }, 10000);
}