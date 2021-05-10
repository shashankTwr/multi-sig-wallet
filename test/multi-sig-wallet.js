const chai = require("chai")
chai.use(require("chai-as-promised"))

const MultiSigWallet = artifacts.require("MultiSigWallet")

contract("MultiSigWallet", accounts => {
	const owners = [ accounts[0],accounts[1],accounts[2]]
	const NUM_CONFIRMATIONS_REQUIRED = 2

	let wallet 
	describe("executeTransaction", ()=>{
		beforeEach(async () =>{
			wallet = await MultiSigWallet.new(owners,NUM_CONFIRMATIONS_REQUIRED)
			await wallet.submitTransaction(owners[0], 0, "0x0")
			await wallet.confirmTransaction(0, {from: owners[0]})
			await wallet.confirmTransaction(0, {from: owners[1]})
		})

		it("should execute", async() => {

			const res = await wallet.executeTransaction(0, {from:owners[0]})
			const { logs } = res

			assert.equal(logs[0].event, "ExecuteTransaction")
			assert.equal(logs[0].args.owner, owners[0])
			assert.equal(logs[0].args.txIndex, 0)

			const tx = await wallet.getTransaction(0)
			assert.equal(tx.executed, true)
		})

		it("reject executed transaction", async() =>{
			await 
		})
	})
	
})