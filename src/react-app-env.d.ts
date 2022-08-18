/// <reference types="react-scripts" />
//Property 'ethereum' does not exist on type 'Window & typeof globalThis'
interface Window {
    ethereum: any
}