## Integration Patterns

### With API Design Skill

When presenting API strategy to executives:

1. Use **executive-data-storytelling** to structure narrative (What: current API challenges, Why: root causes, Next: proposed architecture)
2. Use **api-design** skill to ensure technical accuracy of recommendations
3. Apply depersonalization if discussing API failures or technical debt
4. Translate technical benefits (scalability, maintainability) to business outcomes (faster feature delivery, reduced maintenance costs)

**Example**: "Our monolithic API limits feature velocity (What). Each new feature requires testing the entire system, taking 3 weeks (Why). Microservices architecture enables independent deployment, reducing time-to-market from 3 weeks to 3 days (Next). This accelerates our product roadmap, supporting Growth priority."

### With Security Review Skill

When presenting security findings to board:

1. Use **security-review** skill to conduct thorough analysis
2. Use **executive-data-storytelling** to present findings without creating panic
3. Apply depersonalization for vulnerabilities (focus on gaps, not blame)
4. Use "reassured" emotional tone for contained incidents, "concern" for urgent action items
5. Connect security investments to Financial priority (avoiding breach costs) and Technology priority (secure-by-design)

**Example**: "Penetration testing identified 12 vulnerabilities (What). 8 are low-risk, addressed in normal sprint cycle. 4 require immediate attention: [list]. These gaps exist because legacy authentication system lacks modern controls (Why - depersonalized). Recommendation: Implement zero-trust architecture by Q4, eliminating 95% of identified risks. Investment: $340K. Breach avoidance value: $8M-15M based on industry data (Next)."

### With Feature Flags Skill

When explaining feature flag strategy:

1. Use **feature-flags** skill for technical implementation details
2. Use **executive-data-storytelling** to justify gradual rollout approach
3. Connect to Growth priority (faster iteration, lower risk) and Technology priority (modern deployment)
4. Use "reassured" tone to address executive concerns about complexity

**Example**: "Feature flags enable us to deploy code to production without immediately exposing to all users (What). This reduces deployment risk 90% and enables A/B testing to optimize features before full launch (Why). Recommendation: Implement feature flag system in Q3. This accelerates our release cycle from monthly to weekly, supporting 4x faster product iteration (Next - connects to Growth priority)."
