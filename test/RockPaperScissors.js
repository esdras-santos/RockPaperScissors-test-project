const {expect, assert} = require("chai")
const { ethers } = require("hardhat")
const keccak256 = require('keccak256')


describe('RockPaperScissors', () =>{

    it("test the deposit function", async ()=>{
        const [owner] = await ethers.getSigners()
        const contract = await ethers.getContractFactory("RockPaperScissors")
        const rps = await contract.deploy()
        try {
            await rps.deposit({from:owner.address, value: '10000'})    
        } catch (e) {
            assert(e.message.indexOf("revert") >= 0, "not enough")
        }
        await rps.deposit({from:owner.address, value: '1000000000000000000'})   
    })

    it("test the bet function", async () =>{
        const [owner,addr1,addr2,addr3] = await ethers.getSigners()
        const contract = await ethers.getContractFactory("RockPaperScissors")
        const rps = await contract.deploy()
        await rps.deposit({from:owner.address, value: '1000000000000000000'})
        await rps.connect(addr1).deposit({from:addr1.address, value: '1000000000000000000'})
        
        await rps.bet(keccak256("rock"),{from:owner.address})
        await rps.connect(addr1).bet(keccak256("paper"),{from:addr1.address})
        await rps.evaluate(owner.address,addr1.address)
        let winner = await rps.getWinner()
        expect(winner).to.be.equal(addr1.address)
    
        await rps.connect(addr2).deposit({from:addr2.address, value: '1000000000000000000'})
        await rps.connect(addr3).deposit({from:addr3.address, value: '1000000000000000000'})
        await rps.connect(addr2).bet(keccak256("paper"))
        await rps.connect(addr3).bet(keccak256("rock"))
        await rps.evaluate(addr2.address,addr3.address)
        winner = await rps.getWinner()
        expect(winner).to.be.equal(addr2.address)

      
    })

})