;; JoseCoin - A SIP-010-like fungible token for Stacks

;; Import local SIP-010 trait and declare compliance
(use-trait sip010 .sip010-ft-trait.sip-010-ft-trait)
(impl-trait .sip010-ft-trait.sip-010-ft-trait)

;; Define the fungible token asset
(define-fungible-token josecoin)

;; Token metadata
(define-constant TOKEN_NAME "JoseCoin")
(define-constant TOKEN_SYMBOL "JOSE")
(define-constant TOKEN_DECIMALS u6)

;; Error codes
(define-constant ERR_UNAUTHORIZED u100)
(define-constant ERR_ALREADY_INITIALIZED u101)
(define-constant ERR_NOT_INITIALIZED u102)
(define-constant ERR_INVALID_AMOUNT u103)
(define-constant ERR_BAD_SENDER u104)

;; State
(define-data-var admin (optional principal) none)
(define-data-var initialized bool false)

;; SIP-010 required read-onlys
(define-read-only (get-name)
  (ok TOKEN_NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply josecoin))
)

(define-read-only (get-balance-of (who principal))
  (ok (ft-get-balance josecoin who))
)

;; Initialize the token: set admin and optionally mint an initial supply to the caller.
;; Can only be called once.
(define-public (initialize (initial-supply uint))
  (begin
    (asserts! (is-none (var-get admin)) (err ERR_ALREADY_INITIALIZED))
    (var-set admin (some tx-sender))
    (if (> initial-supply u0)
        (ft-mint? josecoin initial-supply tx-sender)
        (ok true)
    )
  )
)

;; SIP-010 transfer
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err ERR_BAD_SENDER))
    (asserts! (> amount u0) (err ERR_INVALID_AMOUNT))
    (ft-transfer? josecoin amount sender recipient)
  )
)

;; Admin-only mint
(define-public (mint (amount uint) (to principal))
  (begin
    (asserts! (is-some (var-get admin)) (err ERR_NOT_INITIALIZED))
    (asserts!
      (match (var-get admin) a (is-eq a tx-sender) false)
      (err ERR_UNAUTHORIZED)
    )
    (asserts! (> amount u0) (err ERR_INVALID_AMOUNT))
    (ft-mint? josecoin amount to)
  )
)

;; Admin-only burn from a specific sender (requires admin to orchestrate burn)
(define-public (burn-from (amount uint) (from principal))
  (begin
    (asserts! (is-some (var-get admin)) (err ERR_NOT_INITIALIZED))
    (asserts!
      (match (var-get admin) a (is-eq a tx-sender) false)
      (err ERR_UNAUTHORIZED)
    )
    (asserts! (> amount u0) (err ERR_INVALID_AMOUNT))
    (ft-burn? josecoin amount from)
  )
)

;; Allow any holder to burn their own tokens
(define-public (burn (amount uint))
  (begin
    (asserts! (> amount u0) (err ERR_INVALID_AMOUNT))
    (ft-burn? josecoin amount tx-sender)
  )
)

;; Admin management
(define-read-only (get-admin)
  (ok (var-get admin))
)

(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-some (var-get admin)) (err ERR_NOT_INITIALIZED))
    (asserts!
      (match (var-get admin) a (is-eq a tx-sender) false)
      (err ERR_UNAUTHORIZED)
    )
    (var-set admin (some new-admin))
    (ok true)
  )
)
