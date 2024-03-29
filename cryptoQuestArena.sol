// SPDX-License-Identifier: UNLICENSED
// ----------------------------------------------------------------------------
// 'CryptoQuest Arena' token contract
// Symbol      : CQA
// Name        : CryptoQuest Arena
// Total supply: 2,000,000,000
// Decimals    : 18
// ----------------------------------------------------------------------------

pragma solidity ^0.8.0;

interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the BEP20 token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal pure returns (bytes memory) {
        return msg.data;
    }
}

contract Ownable is Context {
  address private _owner;
  address public pendingOwner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
constructor ()  {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */

  function renounceOwnership() public onlyOwner {
    _owner = address(0);
    pendingOwner = address(0);
    emit OwnershipTransferred(_owner, address(0));
}

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
 function transferOwnership(address newOwner) public onlyOwner {
    require(address(0) != newOwner, "pendingOwner set to the zero address.");
    pendingOwner = newOwner;
}


  /**
   * @dev Claim ownership of the contract to a new account (`newOwner`).
   * 
   */

function claimOwnership() public {    
    require(msg.sender == pendingOwner, "caller != pending owner");
    _owner = pendingOwner;
    pendingOwner = address(0);
    emit OwnershipTransferred(_owner, pendingOwner);
}
}

contract CryptoQuestArena is Context, IERC20, Ownable {
  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private  _totalSupply;
  uint8 private immutable _decimals;
  string private  _symbol;
  string private  _name;
  uint256  private immutable _cap;


  event TokensUnlocked(address indexed target, uint256 amountUnlocked);

  event TokensVested(
    address indexed recipient,
    uint256 initialLock,
    uint256 totalAmount,
    uint256 openingPercentage
    );

 struct LockDetails {
        uint256 startTime;
        uint256 initialLock;
        uint256 lockedToken;
        uint256 remainingLockedToken;
        uint256 monthCount;
        uint256 openingPercentage;
    }

    mapping(address => LockDetails) public locks;


  constructor()  {
    _name = "CryptoQuest Arena";
    _symbol = "CQA";
    _decimals = 18;
    _totalSupply = 2_000_000_000 * 10 ** uint256(_decimals);
    _balances[msg.sender] = _totalSupply;
    _cap = _totalSupply;
    
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  /**
   * @dev Returns the BEP20 token owner.
   */
  function getOwner() external override view returns (address) {
    return owner();
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external override view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external override view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external view override returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() external override view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) override public view returns (uint256) {
    return _balances[account];
  }


  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) override external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20}.
   */
  function allowance(address owner, address spender) override external view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) override external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) override external returns (bool) {
     _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
    _transfer(sender, recipient, amount);
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(addedValue>0,"addedValue should be higher than zero");
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
     require(subtractedValue > 0,"subtractedValue should be higher than zero");
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
    return true;
  }
  
  
   /* * @dev Burns a specific amount of tokens.
     * @param value The amount of lowest token units to be burned.
     */
    function burn(uint256 value) public onlyOwner {
      _burn(msg.sender, value);
    }
    
  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(amount>0,"amount should be higher than zero");
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(sender != recipient, "Invalid target");

    if (locks[sender].lockedToken > 0) {
            uint256 withdrawable = balanceOf(sender) - locks[sender].remainingLockedToken;
            require(amount <= withdrawable,"Not enough Unlocked token Available");
    }
    
    _balances[sender] = _balances[sender] - amount;
    _balances[recipient] = _balances[recipient] + amount;
    emit Transfer(sender, recipient, amount);
  }


    /**
     * @dev it unlocks token from vesting period ,
     * locked token for initially for initial days than unlock *openingPercentage of locked token every month
     */ 

    function unlock(address target_) external {
        require(target_ != address(0), "Target address can not be zero address");
        uint256 startTime = locks[target_].startTime;
        uint256 lockedToken = locks[target_].lockedToken;
        uint256 remainingLockedToken = locks[target_].remainingLockedToken;
        uint256 monthCount = locks[target_].monthCount;
        uint256 initialLock = locks[target_].initialLock;
        uint256 openingPercentage = locks[target_].openingPercentage;
        
        require(remainingLockedToken != 0, "All tokens are unlocked");

        require(
            block.timestamp > startTime + (initialLock * 1 days),
            "UnLocking period is not opened"
        );
        uint256 timePassed = block.timestamp -
            (startTime + (initialLock * 1 days));

        uint256 monthNumber = (uint256(timePassed) + (uint256(30 days) - 1)) /
            uint256(30 days);
        uint256 installment = uint256(100) / openingPercentage;
        
        if(monthNumber>installment) monthNumber=installment;

        uint256 remainingMonth = monthNumber - monthCount;

       if (remainingMonth > installment) remainingMonth = installment;
        require(remainingMonth > 0, "Releasable token till now is released");

        uint256 receivableToken = (lockedToken * (remainingMonth * openingPercentage)) / 100;

        locks[target_].monthCount += remainingMonth; 
        remainingLockedToken -= receivableToken;
        locks[target_].remainingLockedToken = remainingLockedToken;
        if (locks[target_].remainingLockedToken == 0) {
            delete locks[target_];
        }
        emit TokensUnlocked(target_, receivableToken);
    }


    /** @dev Transfer with lock
     * @param recipient The recipient address.
     * @param tAmount Amount that has to be locked (with decimals)
     * @param initialLock duration in days for locking
     */

    function transferWithVesting(
        address recipient,
        uint256 tAmount,
        uint256 initialLock,
        uint256 openingPercentage
    ) external onlyOwner {
        require(tAmount>0,"tAmount should be higher than zero");
        require(recipient != address(0), "Invalid target");
        require(initialLock >0 && initialLock<=uint256(315360000), "Can not be more than 10 Years");
        require(
            locks[recipient].lockedToken == 0,
            "This address is already in vesting period"
        );

        require(
            openingPercentage != 0 && uint256(100) % openingPercentage == 0,
            "Invalid openingPercentage, accepts only (1, 2, 4, 5, 10, 20, 25, 50)"
        );


        _transfer(_msgSender(), recipient, tAmount);
        locks[recipient] = LockDetails(
            block.timestamp,
            initialLock,
            tAmount,
            tAmount,
            0,
            openingPercentage
        );

         emit TokensVested(recipient, initialLock, tAmount, openingPercentage);

    }
 

  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements
   *
   * - `account` cannot be the zero address.
   * - `amount` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal {
    require(amount>0,"amount should be higher than zero");
    require(account != address(0), "BEP20: burn from the zero address");
    _balances[account] = _balances[account] - amount;
    _totalSupply = _totalSupply - amount;
    emit Transfer(account, address(0), amount);
  }
  
   /** @dev mint some token to an address
     */ 
    function _mint(address account, uint256 amount) internal onlyOwner {
        require(amount>0,"amount should be higher than zero");
        require(account != address(0), "BEP20: mint to the zero address");
        require(_totalSupply + amount <= _cap, "ERC20Capped: cap exceeded");
        _totalSupply = _totalSupply + amount;
        emit Transfer(address(0), account, amount);
    }
    

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
}
