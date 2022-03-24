# Contracts Here

<img src="https://github.com/MetapoLabs/metapo-docs/blob/main/MeTaPo.png?raw=true">
<br>
<br>
We borrowed the staking rules as in DEFI, we call it pointing.
<br>
<br>
When you login, you'll have MetapoBalance according to the total amount of USDT/USDC/DAI/BUSD..,
the MetapoBalance can't transfer, when your USD balance change, Oracle will get your last USD 
balance, and set to MetapoBalance, this is the only way to change MetapoBalance. then MetapoBalance
contract will notify the IBalanceListener contracts, Entry contract and more.
<br>
<br>
When you pressing the like button on an Entry, that is pointing(as staking) MetapoBalance to Entry,
but your MetapoBalance dosen't change, the Entry records how much you have pointing, and the hot 
will increase.
<br>
<br>
If your USD balance increase, you have more MetapoBalance for pointing.
<br>
<br>
If your USD balance decrease, your MetapoBalance decrease, the amount that Entry records how much
you have pointing, maybe larger then your MetapoBalance. So, your pointing Entries need to change
to unlike(revert-point), and the hot decrease, until the amount of your pointing is less then 
your MetapoBalance.
<br>
<br>
A basic testing is done, everything goes well, and need out-of-gas testing.
<br>
In thinking of out-of-gas, the notify feature may move to offchain, maybe.
<br>
<br>
<br>
<br>


## MetapoBalance Contract
Oracle call setBalance() for each account, and it'll notify the IBalanceListener(Entry).
### (write) setBalance
When user's USD balance changed in other chains, Oracle should call this.
### params 
    account     user's account address, type address
    newValue    user's new USD balance, type uint
### returns   
    null
<br>

### (write) addBalanceListener
IBalanceListener should call this once.
### params 
    contractAddress     when user's USD balance changed, it'll notify the contract, type address  
### returns   
    null
<br>

### (read) balanceOf
View each account's MetapoBalance.
### params 
    account     user's account address, type address
### returns   
    balance     account' MetapoBalance, type uint
<br>


## Entry Contract
Each Entry is a post NFT.
### (write) setMetapoBalanceContract
For init, chould call once.
### params 
    contractAddress     the MetapoBalance contract address，type address
### returns
    null
<br>

### (write) mint
Mint means post from social network.
### params 
    upIds       each Entry can @ serveral Entries，type uint[]
    thumbnail   what this NFT looks, it could be URL or Base64, type string
    content     the post content, type string
### returns
    null
<br>

### (write) like
User press the Like button, and point his MetapoBalance to the Entry (as staking).
### params 
    tokenId     Id of Entry，type uint
    amount      How much MetapoBalance that user point.
### returns
    null
<br>

### (write) unlike
User press the Unlike button, and revert-point his MetapoBalance from the Entry (as unstaking).
### params 
    tokenId     Id of Entry，type uint
### returns
    null
<br>

### (write) onMetapoBalanceChange
When MetapoBalance contract notify, this will be called.
### params 
    account         who's USD balance changed，type address
    increase        dose the balance increase? type bool
    changeValue     the changed value，type uint
### returns
    null
<br>

### (read) tokenIdToInfo
Get the Entry's info.
### params 
    tokenId     Id of Entry，type uint
### returns
    info        including upIds\thumbnail\content\author\hot, type struct
<br>

### (read) minted
How many Entries are minted, the tokenId is minted from 1.
### params 
    null
### returns
    length  total of Entries, type uint
<br>

### (read) accountToPointed
MetapoBalance amount of an account pointing to all Entries.
### params 
    account         user's account address, type address
### returns
    totalPointed    total of Pointed MetapoBalance amount, type uint
<br>
