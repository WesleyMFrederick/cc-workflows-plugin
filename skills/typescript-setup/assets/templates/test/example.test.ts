import { describe, expect, it } from "vitest";
import { add, greet } from "../src/example.js";

describe("example module", () => {
	it("should greet a person", () => {
		const result = greet("World");
		expect(result).toBe("Hello, World!");
	});

	it("should add two numbers", () => {
		const result = add(2, 3);
		expect(result).toBe(5);
	});
});