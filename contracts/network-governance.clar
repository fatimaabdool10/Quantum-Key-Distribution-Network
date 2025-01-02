;; Network Governance Contract

(define-map proposals
  { proposal-id: uint }
  {
    proposer: principal,
    title: (string-utf8 100),
    description: (string-utf8 1000),
    proposal-type: (string-ascii 20),
    status: (string-ascii 20),
    votes-for: uint,
    votes-against: uint,
    start-block: uint,
    end-block: uint
  }
)

(define-map votes
  { proposal-id: uint, voter: principal }
  { vote: bool }
)

(define-data-var proposal-count uint u0)

(define-public (create-proposal (title (string-utf8 100)) (description (string-utf8 1000)) (proposal-type (string-ascii 20)) (voting-period uint))
  (let
    (
      (new-proposal-id (+ (var-get proposal-count) u1))
    )
    (map-set proposals
      { proposal-id: new-proposal-id }
      {
        proposer: tx-sender,
        title: title,
        description: description,
        proposal-type: proposal-type,
        status: "active",
        votes-for: u0,
        votes-against: u0,
        start-block: block-height,
        end-block: (+ block-height voting-period)
      }
    )
    (var-set proposal-count new-proposal-id)
    (ok new-proposal-id)
  )
)

(define-public (vote (proposal-id uint) (vote-for bool))
  (let
    (
      (proposal (unwrap! (map-get? proposals { proposal-id: proposal-id }) (err u404)))
    )
    (asserts! (< block-height (get end-block proposal)) (err u405))
    (asserts! (is-none (map-get? votes { proposal-id: proposal-id, voter: tx-sender })) (err u406))
    (map-set votes { proposal-id: proposal-id, voter: tx-sender } { vote: vote-for })
    (if vote-for
      (map-set proposals { proposal-id: proposal-id }
        (merge proposal { votes-for: (+ (get votes-for proposal) u1) }))
      (map-set proposals { proposal-id: proposal-id }
        (merge proposal { votes-against: (+ (get votes-against proposal) u1) }))
    )
    (ok true)
  )
)

(define-public (end-proposal (proposal-id uint))
  (let
    (
      (proposal (unwrap! (map-get? proposals { proposal-id: proposal-id }) (err u404)))
    )
    (asserts! (>= block-height (get end-block proposal)) (err u403))
    (ok (map-set proposals { proposal-id: proposal-id }
      (merge proposal {
        status: (if (> (get votes-for proposal) (get votes-against proposal)) "passed" "rejected")
      })
    ))
  )
)

(define-read-only (get-proposal (proposal-id uint))
  (ok (map-get? proposals { proposal-id: proposal-id }))
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
  (ok (map-get? votes { proposal-id: proposal-id, voter: voter }))
)

(define-read-only (get-proposal-count)
  (ok (var-get proposal-count))
)

