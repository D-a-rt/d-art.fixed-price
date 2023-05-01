const axios = require('axios')

export const sendJSONToIPFS = async (inputData: any, fileName: string) => {
    if (inputData) {
        try {
            const resFile = await axios({
                method: "post",
                url: "https://api.pinata.cloud/pinning/pinJSONToIPFS",
                data: JSON.stringify({
                    pinataMetadata: { name: fileName },
                    pinataOptions: { cidVersion: 1 },
                    pinataContent: inputData
                }),
                headers: {
                    'Authorization': `Bearer ${process.env.PINATA_JWT}`,
                    "Content-Type": "application/json"
                },
            });

            return resFile.data.IpfsHash
        } catch (error) {
            console.log(`Failed to send JSON to IPFS, err: ${error}`);
            throw Error("Error sending file to IPFS.")
        }
    }
}