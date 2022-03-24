# Contracts Here
A basic testing is done, everything goes well, and need out-of-gas testing.
<br>
In thinking of out-of-gas, the notify feature may move to offchain, maybe.
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
