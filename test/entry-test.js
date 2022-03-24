const { expect, assert } = require('chai')
const { BigNumber, utils } = require('ethers')
const fs = require('fs')
const hre = require('hardhat')


describe('entry-test', function () {
	let accounts
    let deployer
	let metapoBalance
	let entry

	before(async function () {
		accounts = await ethers.getSigners()
        deployer = accounts[0].address
	})

	it('deploy', async function () {
		const MetapoBalance = await ethers.getContractFactory('MetapoBalance')
		metapoBalance = await MetapoBalance.deploy()
		await metapoBalance.deployed()
		console.log('MetapoBalance deployed:', metapoBalance.address)

		const Entry = await ethers.getContractFactory('Entry')
		entry = await Entry.deploy()
		await entry.deployed()
		console.log('Entry deployed:', entry.address)

        await entry.setMetapoBalanceContract(metapoBalance.address)
        await metapoBalance.setBalance(deployer, 10000)
	})

	it('mint', async function () {
		await entry.mint([0], 'http://thumbnail1', 'this is content1')
		console.log('mint done')

        await entry.mint([1], 'http://thumbnail2', 'this is content2')
		console.log('mint done')
	})

    it('like', async function () {
		await entry.like(2, 100)
		console.log('like done')

        print(1)
        print(2)

        console.log('pointed', await entry.accountToPointed(deployer))
        console.log('metapoBalance', await metapoBalance.balanceOf(deployer))
	})

    // it('unlike', async function () {
	// 	await entry.unlike(2)
	// 	console.log('unlike done')

    //     print(1)
    //     print(2)

    //     console.log('pointed', await entry.accountToPointed(deployer))
    //     console.log('metapoBalance', await metapoBalance.balanceOf(deployer))

    //     console.log('getlistItem', await entry.getlistItem(deployer, 0))
	// })

    it('setBalance', async function () {
		await metapoBalance.setBalance(deployer, 10)
		console.log('setBalance done')

        print(1)
        print(2)

        console.log('pointed', await entry.accountToPointed(deployer))
        console.log('metapoBalance', await metapoBalance.balanceOf(deployer))
	})
    
    async function print(tokenId) {
        let info = await entry.tokenIdToInfo(tokenId)
        info.tokenId = tokenId
        console.log(info)
    }


	function getAbi(jsonPath) {
		let file = fs.readFileSync(jsonPath)
		let abi = JSON.parse(file.toString()).abi
		return abi
	}

	function m(num) {
		return BigNumber.from('1000000000000000000').mul(num)
	}

	function d(bn) {
		return bn.div('1000000000000000').toNumber() / 1000
	}

	function b(num) {
		return BigNumber.from(num)
	}

	function n(bn) {
		return bn.toNumber()
	}

	function s(bn) {
		return bn.toString()
	}
})