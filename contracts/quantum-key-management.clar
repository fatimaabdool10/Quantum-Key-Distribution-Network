;; Quantum Key Management Contract

(define-map quantum-keys
  { key-id: uint }
  {
    owner: principal,
    public-key: (buff 32),
    creation-time: uint,
    expiration-time: uint,
    status: (string-ascii 20)
  }
)

(define-map key-requests
  { request-id: uint }
  {
    requester: principal,
    recipient: principal,
    status: (string-ascii 20),
    creation-time: uint
  }
)

(define-data-var key-count uint u0)
(define-data-var request-count uint u0)

(define-public (generate-quantum-key (public-key (buff 32)) (expiration-time uint))
  (let
    (
      (new-key-id (+ (var-get key-count) u1))
    )
    (map-set quantum-keys
      { key-id: new-key-id }
      {
        owner: tx-sender,
        public-key: public-key,
        creation-time: block-height,
        expiration-time: expiration-time,
        status: "active"
      }
    )
    (var-set key-count new-key-id)
    (ok new-key-id)
  )
)

(define-public (request-key-exchange (recipient principal))
  (let
    (
      (new-request-id (+ (var-get request-count) u1))
    )
    (map-set key-requests
      { request-id: new-request-id }
      {
        requester: tx-sender,
        recipient: recipient,
        status: "pending",
        creation-time: block-height
      }
    )
    (var-set request-count new-request-id)
    (ok new-request-id)
  )
)

(define-public (approve-key-exchange (request-id uint))
  (let
    (
      (request (unwrap! (map-get? key-requests { request-id: request-id }) (err u404)))
    )
    (asserts! (is-eq (get recipient request) tx-sender) (err u403))
    (ok (map-set key-requests
      { request-id: request-id }
      (merge request { status: "approved" })
    ))
  )
)

(define-public (revoke-quantum-key (key-id uint))
  (let
    (
      (key (unwrap! (map-get? quantum-keys { key-id: key-id }) (err u404)))
    )
    (asserts! (is-eq (get owner key) tx-sender) (err u403))
    (ok (map-set quantum-keys
      { key-id: key-id }
      (merge key { status: "revoked" })
    ))
  )
)

(define-read-only (get-quantum-key (key-id uint))
  (ok (map-get? quantum-keys { key-id: key-id }))
)

(define-read-only (get-key-request (request-id uint))
  (ok (map-get? key-requests { request-id: request-id }))
)

(define-read-only (get-key-count)
  (ok (var-get key-count))
)

(define-read-only (get-request-count)
  (ok (var-get request-count))
)

