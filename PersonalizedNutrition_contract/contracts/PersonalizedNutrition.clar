
;; title: PersonalizedNutrition
;; version: 1.0.0
;; summary: Synthetic assets smart contract for personalized health and nutrition technology exposure
;; description: This contract manages synthetic assets representing personalized nutrition and health data,
;;              allowing users to create profiles, track nutrition goals, and participate in health-focused DeFi.

;; traits
;;

;; token definitions
(define-fungible-token pnut-token)

;; constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-AUTHORIZED (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-INSUFFICIENT-BALANCE (err u103))
(define-constant ERR-PROFILE-NOT-FOUND (err u104))
(define-constant ERR-PROFILE-EXISTS (err u105))
(define-constant ERR-INVALID-GOAL (err u106))
(define-constant ERR-GOAL-NOT-FOUND (err u107))

;; Initial token supply
(define-constant INITIAL-SUPPLY u1000000000000) ;; 1M tokens with 6 decimals

;; data vars
(define-data-var contract-paused bool false)
(define-data-var total-profiles uint u0)
(define-data-var token-name (string-ascii 32) "PersonalizedNutrition")
(define-data-var token-symbol (string-ascii 10) "PNUT")
(define-data-var token-decimals uint u6)

;; data maps
;; User nutrition profiles
(define-map user-profiles
  principal
  {
    profile-id: uint,
    created-at: uint,
    height: uint, ;; in cm
    weight: uint, ;; in kg * 100 (for 2 decimal precision)
    age: uint,
    activity-level: uint, ;; 1-5 scale
    dietary-preferences: (string-ascii 100),
    health-goals: (string-ascii 200),
    is-active: bool
  }
)

;; Nutrition goals and tracking
(define-map nutrition-goals
  {user: principal, goal-id: uint}
  {
    goal-type: (string-ascii 50), ;; "weight-loss", "muscle-gain", "maintenance", etc.
    target-calories: uint,
    target-protein: uint, ;; in grams
    target-carbs: uint,   ;; in grams
    target-fat: uint,     ;; in grams
    start-date: uint,
    end-date: uint,
    is-completed: bool,
    progress-score: uint  ;; 0-100
  }
)

;; Daily nutrition logs
(define-map daily-logs
  {user: principal, date: uint}
  {
    calories-consumed: uint,
    protein-consumed: uint,
    carbs-consumed: uint,
    fat-consumed: uint,
    water-intake: uint, ;; in ml
    exercise-minutes: uint,
    logged-at: uint
  }
)

;; Token staking for nutrition incentives
(define-map user-stakes
  principal
  {
    staked-amount: uint,
    stake-start: uint,
    last-reward-claim: uint,
    goal-achievements: uint
  }
)

;; Authorized nutritionists and health professionals
(define-map authorized-professionals
  principal
  {
    license-number: (string-ascii 50),
    specialization: (string-ascii 100),
    authorized-at: uint,
    is-active: bool
  }
)

;; public functions

;; Initialize the contract (only called once)
(define-public (initialize)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
    (try! (ft-mint? pnut-token INITIAL-SUPPLY CONTRACT-OWNER))
    (ok true)
  )
)

;; Create a nutrition profile
(define-public (create-profile (height uint) (weight uint) (age uint) (activity-level uint)
                              (dietary-preferences (string-ascii 100)) (health-goals (string-ascii 200)))
  (let (
    (profile-id (+ (var-get total-profiles) u1))
    (current-block block-height)
  )
    (asserts! (is-none (map-get? user-profiles tx-sender)) ERR-PROFILE-EXISTS)
    (asserts! (and (> height u0) (> weight u0) (> age u0)) ERR-INVALID-AMOUNT)
    (asserts! (and (<= activity-level u5) (>= activity-level u1)) ERR-INVALID-AMOUNT)

    (map-set user-profiles tx-sender {
      profile-id: profile-id,
      created-at: current-block,
      height: height,
      weight: weight,
      age: age,
      activity-level: activity-level,
      dietary-preferences: dietary-preferences,
      health-goals: health-goals,
      is-active: true
    })

    (var-set total-profiles profile-id)
    (try! (ft-mint? pnut-token u100000000 tx-sender)) ;; Mint 100 PNUT tokens as welcome bonus
    (ok profile-id)
  )
)

;; Update nutrition profile
(define-public (update-profile (height uint) (weight uint) (age uint) (activity-level uint)
                              (dietary-preferences (string-ascii 100)) (health-goals (string-ascii 200)))
  (let (
    (current-profile (unwrap! (map-get? user-profiles tx-sender) ERR-PROFILE-NOT-FOUND))
  )
    (asserts! (and (> height u0) (> weight u0) (> age u0)) ERR-INVALID-AMOUNT)
    (asserts! (and (<= activity-level u5) (>= activity-level u1)) ERR-INVALID-AMOUNT)

    (map-set user-profiles tx-sender (merge current-profile {
      height: height,
      weight: weight,
      age: age,
      activity-level: activity-level,
      dietary-preferences: dietary-preferences,
      health-goals: health-goals
    }))
    (ok true)
  )
)

;; Set nutrition goal
(define-public (set-nutrition-goal (goal-id uint) (goal-type (string-ascii 50))
                                  (target-calories uint) (target-protein uint)
                                  (target-carbs uint) (target-fat uint)
                                  (duration-days uint))
  (let (
    (start-date block-height)
    (end-date (+ block-height (* duration-days u144))) ;; Assuming ~144 blocks per day
  )
    (asserts! (is-some (map-get? user-profiles tx-sender)) ERR-PROFILE-NOT-FOUND)
    (asserts! (> duration-days u0) ERR-INVALID-GOAL)
    (asserts! (> target-calories u0) ERR-INVALID-GOAL)

    (map-set nutrition-goals {user: tx-sender, goal-id: goal-id} {
      goal-type: goal-type,
      target-calories: target-calories,
      target-protein: target-protein,
      target-carbs: target-carbs,
      target-fat: target-fat,
      start-date: start-date,
      end-date: end-date,
      is-completed: false,
      progress-score: u0
    })
    (ok true)
  )
)

;; Log daily nutrition data
(define-public (log-daily-nutrition (date uint) (calories uint) (protein uint)
                                   (carbs uint) (fat uint) (water uint) (exercise-minutes uint))
  (begin
    (asserts! (is-some (map-get? user-profiles tx-sender)) ERR-PROFILE-NOT-FOUND)
    (asserts! (> calories u0) ERR-INVALID-AMOUNT)

    (map-set daily-logs {user: tx-sender, date: date} {
      calories-consumed: calories,
      protein-consumed: protein,
      carbs-consumed: carbs,
      fat-consumed: fat,
      water-intake: water,
      exercise-minutes: exercise-minutes,
      logged-at: block-height
    })

    ;; Reward user with tokens for logging
    (try! (ft-mint? pnut-token u1000000 tx-sender)) ;; 1 PNUT token reward
    (ok true)
  )
)

;; Stake tokens for nutrition incentives
(define-public (stake-tokens (amount uint))
  (begin
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (asserts! (>= (ft-get-balance pnut-token tx-sender) amount) ERR-INSUFFICIENT-BALANCE)

    (try! (ft-transfer? pnut-token amount tx-sender (as-contract tx-sender)))

    (let (
      (current-stake (default-to {staked-amount: u0, stake-start: u0, last-reward-claim: u0, goal-achievements: u0}
                                 (map-get? user-stakes tx-sender)))
    )
      (map-set user-stakes tx-sender {
        staked-amount: (+ (get staked-amount current-stake) amount),
        stake-start: block-height,
        last-reward-claim: block-height,
        goal-achievements: (get goal-achievements current-stake)
      })
    )
    (ok true)
  )
)

;; Claim staking rewards
(define-public (claim-rewards)
  (let (
    (stake-info (unwrap! (map-get? user-stakes tx-sender) ERR-NOT-AUTHORIZED))
    (blocks-staked (- block-height (get last-reward-claim stake-info)))
    (reward-amount (* (get staked-amount stake-info) blocks-staked u100 (/ u1 u144))) ;; Daily reward calculation
  )
    (asserts! (> blocks-staked u0) ERR-INVALID-AMOUNT)

    (try! (as-contract (ft-transfer? pnut-token reward-amount tx-sender tx-sender)))

    (map-set user-stakes tx-sender (merge stake-info {
      last-reward-claim: block-height
    }))
    (ok reward-amount)
  )
)

;; Transfer tokens
(define-public (transfer (amount uint) (recipient principal))
  (begin
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (try! (ft-transfer? pnut-token amount tx-sender recipient))
    (ok true)
  )
)

;; Admin functions
(define-public (authorize-professional (professional principal) (license-number (string-ascii 50))
                                      (specialization (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)

    (map-set authorized-professionals professional {
      license-number: license-number,
      specialization: specialization,
      authorized-at: block-height,
      is-active: true
    })
    (ok true)
  )
)

(define-public (pause-contract)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
    (var-set contract-paused true)
    (ok true)
  )
)

(define-public (unpause-contract)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
    (var-set contract-paused false)
    (ok true)
  )
)

;; read only functions

;; Get user profile
(define-read-only (get-user-profile (user principal))
  (map-get? user-profiles user)
)

;; Get nutrition goal
(define-read-only (get-nutrition-goal (user principal) (goal-id uint))
  (map-get? nutrition-goals {user: user, goal-id: goal-id})
)

;; Get daily log
(define-read-only (get-daily-log (user principal) (date uint))
  (map-get? daily-logs {user: user, date: date})
)

;; Get stake info
(define-read-only (get-stake-info (user principal))
  (map-get? user-stakes user)
)

;; Get token info
(define-read-only (get-token-info)
  {
    name: (var-get token-name),
    symbol: (var-get token-symbol),
    decimals: (var-get token-decimals),
    total-supply: (ft-get-supply pnut-token)
  }
)

;; Get balance
(define-read-only (get-balance (user principal))
  (ft-get-balance pnut-token user)
)

;; Get total profiles
(define-read-only (get-total-profiles)
  (var-get total-profiles)
)

;; Check if contract is paused
(define-read-only (is-contract-paused)
  (var-get contract-paused)
)

;; Check if professional is authorized
(define-read-only (is-authorized-professional (professional principal))
  (match (map-get? authorized-professionals professional)
    auth-info (get is-active auth-info)
    false
  )
)

;; private functions

;; Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor equation
(define-private (calculate-bmr (weight uint) (height uint) (age uint) (is-male bool))
  (if is-male
    (+ (+ (* weight u10) (* height u625)) (- u5000 (* age u500))) ;; Male formula
    (+ (+ (* weight u10) (* height u625)) (- u1610 (* age u500))) ;; Female formula
  )
)

;; Calculate recommended daily calories
(define-private (calculate-daily-calories (bmr uint) (activity-level uint))
  (if (is-eq activity-level u1)
    (* bmr u120 (/ u1 u100)) ;; Sedentary
    (if (is-eq activity-level u2)
      (* bmr u137 (/ u1 u100)) ;; Lightly active
      (if (is-eq activity-level u3)
        (* bmr u155 (/ u1 u100)) ;; Moderately active
        (if (is-eq activity-level u4)
          (* bmr u175 (/ u1 u100)) ;; Very active
          (* bmr u200 (/ u1 u100)) ;; Super active
        )
      )
    )
  )
)
