---

## Decentralized Crowdfunding with Milestones

### The Problem It Solves

In traditional crowdfunding (GoFundMe, Kickstarter), once a creator receives funds, backers have **zero control**. The creator can disappear, misuse funds, or simply never deliver. Your contract fixes this by holding funds **hostage** until work is actually done.

---

## How It Works — The Full Flow

```
Funder sends ETH → Locked in contract
                        ↓
Creator submits "Milestone 1 complete"
                        ↓
Funders vote YES or NO (within 7 days)
                        ↓
YES wins → Creator gets that portion of funds
NO wins  → Funds stay locked or refunded
```

---

## Contract Structure

You'll have one main contract with these core pieces:

**The Campaign struct** — stores everything about a campaign:
```solidity
struct Campaign {
    address owner;
    string title;
    uint256 goal;           // target amount in ETH
    uint256 deadline;       // funding deadline
    uint256 amountRaised;
    bool goalReached;
    uint256 currentMilestone;
}
```

**The Milestone struct** — each campaign has multiple milestones:
```solidity
struct Milestone {
    string description;     // "Ship MVP", "Launch beta"
    uint256 fundPercent;    // e.g. 30 means 30% of funds
    uint256 votesFor;
    uint256 votesAgainst;
    bool approved;
    bool withdrawn;
    uint256 votingDeadline;
}
```

**Key mappings** you'll need:
```solidity
mapping(uint256 => Campaign) public campaigns;
mapping(uint256 => Milestone[]) public milestones;
mapping(uint256 => mapping(address => uint256)) public contributions;
mapping(uint256 => mapping(uint256 => mapping(address => bool))) public hasVoted;
```

---

## The 5 Core Functions

**1. `createCampaign()`** — anyone can launch a campaign, define a goal, deadline, and list of milestones upfront.

**2. `fund(campaignId)`** — funders send ETH. Very similar to FundMe's `fund()`. Their contribution is recorded so they can vote later.

**3. `submitMilestone(campaignId)`** — only the campaign owner calls this. Triggers a voting window (e.g. 7 days).

**4. `vote(campaignId, milestoneId, bool support)`** — funders vote yes or no. Voting power is proportional to how much they contributed (more ETH = more weight).

**5. `releaseFunds(campaignId, milestoneId)`** — callable after voting ends. If YES votes win, the creator gets that milestone's percentage of funds. If NO wins, funds stay locked.

**Bonus — `refund(campaignId)`** — if the funding deadline passes and the goal wasn't reached, funders can pull their ETH back. You already built this logic in FundMe!

---

## What's New Compared to FundMe

| Concept | FundMe | This Project |
|---|---|---|
| Receive ETH | ✅ | ✅ same |
| Send ETH back | ✅ | ✅ same |
| `msg.sender` / `msg.value` | ✅ | ✅ same |
| Structs | ❌ | ✅ new |
| Arrays of structs | ❌ | ✅ new |
| Voting logic | ❌ | ✅ new |
| `block.timestamp` deadlines | ❌ | ✅ new |
| Multiple campaigns | ❌ | ✅ new |

So you're not starting over — you're **stacking** new concepts on a foundation you already understand.

---

## Milestone Breakdown Example

Say someone raises **1 ETH** to build a mobile app with 3 milestones:

```
Milestone 1 → "Publish designs"     → 20% = 0.2 ETH
Milestone 2 → "Launch beta app"     → 50% = 0.5 ETH
Milestone 3 → "1000 active users"   → 30% = 0.3 ETH
```

Funders vote after each one. If the creator abandons the project after milestone 1, the remaining 0.8 ETH stays locked — and funders can vote to refund it.

---

## Chainlink Price Feed (Optional Upgrade)

Since you used Chainlink in FundMe to convert ETH/USD, you can reuse that here to let campaigns set goals in **USD** while accepting ETH. That's a very natural extension of exactly what you built.

---

## Suggested Build Order

1. Start with a **single campaign** (no mappings for multiple yet) — just get the funding + one milestone working
2. Add **multiple campaigns** using a mapping and a `campaignCount` counter
3. Add **voting logic** with a time window
4. Add **proportional voting weight** based on contribution amount
5. Add **Chainlink** for USD-denominated goals

---

## Real-World Applications

- A Nigerian student raising money for school fees with milestone-based releases (term by term)
- A startup raising community funding, releasing funds per development phase
- A community project (borehole, generator) releasing funds to contractor per completed stage

---

Want me to write the full starter contract with Foundry tests included?
