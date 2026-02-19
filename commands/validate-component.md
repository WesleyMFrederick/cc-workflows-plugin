---
description: "Validate component implementation guide against actual code using component-expert agent"
argument-hint: "<component-guide-path>"
---

# Validate Component Guide

Validate component implementation guide against actual code using component-expert agent.

## Input Validation

If no path is provided ($1 is empty), respond with: "Error: Please provide component guide path. Usage: /validate-component '<guide-path>'"

<component-guide-path>
Arguments: $1
</component-guide-path>

## Invoke Component Expert

Invoke the `component-expert` agent to validate @$1 against actual implementation code.
