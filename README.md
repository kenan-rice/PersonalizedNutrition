# PersonalizedNutrition Smart Contract

A comprehensive synthetic assets smart contract providing customized health and nutrition technology exposure on the Stacks blockchain. This contract enables users to create detailed nutrition profiles, set health goals, track daily nutrition intake, and earn token rewards for maintaining healthy habits.

## 🚀 Features

### Core Functionality
- **User Nutrition Profiles**: Create and manage detailed health profiles with physical metrics, activity levels, and dietary preferences
- **Nutrition Goal Setting**: Define personalized nutrition targets including calories, macronutrients, and timeframes
- **Daily Nutrition Logging**: Track daily food intake, water consumption, and exercise activities
- **Token Staking & Rewards**: Stake PNUT tokens and earn rewards for consistent healthy behavior
- **Professional Authorization**: Support for licensed nutritionists and health professionals

### Token Economics
- **PNUT Token**: Native fungible token with 6 decimal precision
- **Welcome Bonus**: 100 PNUT tokens for new profile creation
- **Daily Logging Rewards**: 1 PNUT token for each nutrition log entry
- **Staking Rewards**: Earn additional tokens based on staking duration and goal achievements

### Health Calculations
- **BMR Calculator**: Implements Mifflin-St Jeor equation for Basal Metabolic Rate
- **Daily Calorie Recommendations**: Activity-level adjusted calorie targets
- **Progress Tracking**: Score-based system for goal achievement monitoring

## 🛠 Technical Specifications

- **Blockchain**: Stacks
- **Language**: Clarity 2.0
- **Epoch**: 2.5
- **Token Standard**: SIP-010 Fungible Token
- **Initial Supply**: 1,000,000 PNUT (1M tokens with 6 decimals)
- **Token Symbol**: PNUT
- **Contract Version**: 1.0.0

## 📋 Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development toolkit
- [Node.js](https://nodejs.org/) (v18 or higher)
- [Stacks CLI](https://docs.stacks.co/references/stacks-cli) for deployment

## 🔧 Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd PersonalizedNutrition
   ```

2. **Install dependencies**:
   ```bash
   cd PersonalizedNutrition_contract
   npm install
   ```

3. **Run tests**:
   ```bash
   npm test
   ```

4. **Watch mode for development**:
   ```bash
   npm run test:watch
   ```

## 🎯 Usage Examples

### Creating a Nutrition Profile

```clarity
;; Create a new user profile
(contract-call? .PersonalizedNutrition create-profile
  u175  ;; height in cm
  u7000 ;; weight in kg * 100 (70.00 kg)
  u30   ;; age
  u3    ;; activity level (1-5 scale)
  "vegetarian" ;; dietary preferences
  "weight loss and muscle gain" ;; health goals
)
```

### Setting Nutrition Goals

```clarity
;; Set a 30-day weight loss goal
(contract-call? .PersonalizedNutrition set-nutrition-goal
  u1     ;; goal ID
  "weight-loss" ;; goal type
  u2000  ;; target calories
  u150   ;; target protein (grams)
  u200   ;; target carbs (grams)
  u67    ;; target fat (grams)
  u30    ;; duration in days
)
```

### Logging Daily Nutrition

```clarity
;; Log today's nutrition intake
(contract-call? .PersonalizedNutrition log-daily-nutrition
  u20240115 ;; date (YYYYMMDD format)
  u1950     ;; calories consumed
  u145      ;; protein consumed (grams)
  u190      ;; carbs consumed (grams)
  u65       ;; fat consumed (grams)
  u2500     ;; water intake (ml)
  u45       ;; exercise minutes
)
```

### Staking Tokens

```clarity
;; Stake 1000 PNUT tokens for rewards
(contract-call? .PersonalizedNutrition stake-tokens u1000000000)

;; Claim accumulated staking rewards
(contract-call? .PersonalizedNutrition claim-rewards)
```

## 📚 Contract Functions Documentation

### Public Functions

#### Profile Management
- `create-profile(height, weight, age, activity-level, dietary-preferences, health-goals)` - Create new user profile
- `update-profile(height, weight, age, activity-level, dietary-preferences, health-goals)` - Update existing profile

#### Goal Setting & Tracking
- `set-nutrition-goal(goal-id, goal-type, target-calories, target-protein, target-carbs, target-fat, duration-days)` - Set nutrition targets
- `log-daily-nutrition(date, calories, protein, carbs, fat, water, exercise-minutes)` - Record daily intake

#### Token Operations
- `transfer(amount, recipient)` - Transfer PNUT tokens
- `stake-tokens(amount)` - Stake tokens for rewards
- `claim-rewards()` - Claim staking rewards

#### Administrative Functions
- `initialize()` - Initialize contract (owner only)
- `authorize-professional(professional, license-number, specialization)` - Authorize health professionals
- `pause-contract()` / `unpause-contract()` - Emergency controls

### Read-Only Functions

- `get-user-profile(user)` - Retrieve user profile data
- `get-nutrition-goal(user, goal-id)` - Get specific nutrition goal
- `get-daily-log(user, date)` - Retrieve daily nutrition log
- `get-stake-info(user)` - Get staking information
- `get-token-info()` - Get token metadata
- `get-balance(user)` - Check token balance
- `get-total-profiles()` - Get total number of profiles
- `is-contract-paused()` - Check contract status
- `is-authorized-professional(professional)` - Verify professional authorization

## 🚀 Deployment Guide

### Local Development (Devnet)

1. **Start Clarinet console**:
   ```bash
   clarinet console
   ```

2. **Initialize contract**:
   ```clarity
   (contract-call? .PersonalizedNutrition initialize)
   ```

### Testnet Deployment

1. **Configure network**:
   ```bash
   clarinet deployments generate --testnet
   ```

2. **Deploy contract**:
   ```bash
   clarinet deployments apply --testnet
   ```

### Mainnet Deployment

1. **Final testing**: Ensure all tests pass and security audits are complete

2. **Configure mainnet settings**:
   ```bash
   clarinet deployments generate --mainnet
   ```

3. **Deploy to mainnet**:
   ```bash
   clarinet deployments apply --mainnet
   ```

## 🔒 Security Notes

### Access Controls
- Contract owner has exclusive access to administrative functions
- Profile management is user-specific and non-transferable
- Token operations include balance and authorization checks

### Data Validation
- All numeric inputs are validated for positive values and reasonable ranges
- Activity levels are constrained to 1-5 scale
- Goal durations must be positive
- Profile existence is verified before operations

### Economic Security
- Initial token supply is fixed and controlled
- Staking mechanisms prevent token inflation
- Reward calculations are deterministic and bounded

### Best Practices
- Always initialize the contract after deployment
- Monitor contract pause status before critical operations
- Verify professional authorization before accepting health advice
- Keep private keys secure for token operations

### Audit Recommendations
- Regular security audits before mainnet deployment
- Monitor for unusual staking patterns
- Review professional authorization requests
- Implement rate limiting for high-frequency operations

## 📊 Error Codes

| Code | Error | Description |
|------|-------|-------------|
| u100 | ERR-OWNER-ONLY | Function restricted to contract owner |
| u101 | ERR-NOT-AUTHORIZED | User not authorized for this operation |
| u102 | ERR-INVALID-AMOUNT | Invalid amount or numeric parameter |
| u103 | ERR-INSUFFICIENT-BALANCE | Insufficient token balance |
| u104 | ERR-PROFILE-NOT-FOUND | User profile does not exist |
| u105 | ERR-PROFILE-EXISTS | User profile already exists |
| u106 | ERR-INVALID-GOAL | Invalid goal parameters |
| u107 | ERR-GOAL-NOT-FOUND | Nutrition goal not found |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add comprehensive tests for new functionality
4. Ensure all tests pass
5. Submit a pull request with detailed description

## 📄 License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.

## 🌟 Roadmap

- [ ] Integration with fitness tracking APIs
- [ ] Machine learning-based nutrition recommendations
- [ ] Multi-language support for dietary preferences
- [ ] Mobile application integration
- [ ] Community challenges and leaderboards
- [ ] Integration with healthcare providers
- [ ] Advanced analytics and reporting features

---

**Built with ❤️ for the health and wellness community on Stacks blockchain**