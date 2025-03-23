# STX-Solar-DAO - Decentralized Renewable Asset Investment Smart Contract

## Overview
This Clarity smart contract facilitates the decentralized investment, ownership, and governance of renewable energy assets. It enables investors to purchase shares, participate in governance, and receive revenue distributions from asset-generated income.

## Features
- **Asset Registration**: Allows the contract owner to register renewable energy assets (solar, wind, hydro, biomass) with share-based ownership.
- **Share Purchase**: Investors can buy shares in registered assets, acquiring voting power and revenue rights.
- **Revenue Distribution**: Contract owner can distribute asset-generated revenue to shareholders.
- **Governance & Voting**: Shareholders can submit and vote on proposals that affect asset operations.
- **Asset Metrics**: Each asset tracks key performance indicators such as energy production, efficiency, and maintenance costs.

## Smart Contract Structure

### Constants
- `CONTRACT-OWNER`: The account that deploys the contract.
- `MIN-INVESTMENT`: Minimum required investment per asset (1 STX).
- `SHARE-SCALE`: Used for fractional share calculations.
- `VOTE-THRESHOLD`: Minimum required votes for proposals (75%).
- `MAINTENANCE-WINDOW`: Time interval for maintenance actions (~24 hours in blocks).

### Error Codes
The contract includes predefined error codes for validation and authorization checks, such as:
- `ERR-NOT-AUTHORIZED`: Unauthorized access.
- `ERR-INVALID-AMOUNT`: Invalid share amount.
- `ERR-ASSET-NOT-FOUND`: Asset does not exist.
- `ERR-INSUFFICIENT-SHARES`: Insufficient shares available.

### Data Structures
#### Asset Management
- `assets`: Stores registered renewable energy assets.
- `ownership`: Tracks share ownership and revenue claims.
- `asset-metrics`: Maintains operational statistics for assets.

#### Governance
- `governance-settings`: Defines voting and proposal parameters.
- `proposals`: Manages active and past proposals for asset governance.

### Functions

#### Asset Management
- `register-asset`: Registers a new renewable energy asset.
- `purchase-shares`: Enables users to buy shares in assets.
- `distribute-revenue`: Distributes revenue among shareholders.

#### Governance
- `submit-proposal`: Allows shareholders to propose changes.
- `get-asset-info`: Fetches details of a specific asset.
- `get-ownership-info`: Retrieves ownership data for a given asset.
- `get-asset-metrics`: Retrieves key performance metrics of an asset.
- `get-governance-settings`: Fetches governance configurations.
- `get-proposal-info`: Returns details about a governance proposal.

## Usage
1. **Deploy the contract**: The contract owner deploys the Clarity smart contract.
2. **Register an asset**: The contract owner registers an energy asset.
3. **Investors purchase shares**: Investors buy shares, gaining voting power.
4. **Revenue distribution**: The contract owner distributes generated revenue.
5. **Governance participation**: Shareholders vote on proposals affecting asset operations.
