/*
    This module is responsible for validating forms.
*/

/**
 * Applies validation to a form, blocking it from submitting until all fields pass validation.
 * @param {string} formSelector a CSS selector for the form to apply validation to.
 * @param {Field[]} fields validation rules which must all pass before submitting the form.
 */
export function addFormValidation(formSelector, fields) {
    const form = _find(formSelector);
    form.addEventListener("submit", e => {
        // run all validations - using some() here would stop after first failed validation
        const validationResults = fields.map(f => f.validate());

        if (validationResults.some(vr => vr === false)) {
            e.preventDefault();
        }
    });
}

/**
 * Creates a configurable validator for a form field.
 * @param {string} label displayed in validation messages about this field.
 * @param {string} elementSelector a CSS selector for the form field this validates.
 * @param {string} errorSelector a CSS selector for the HTML element to output error messages to.
 * @returns {Field} a validator you'll need to configure.
 */
export function field(label, elementSelector, errorSelector) {
    const element = _find(elementSelector);
    const errorElement = _find(errorSelector);
    const result = new Field(label, element, errorElement);
    return result;
}

class Field {
    #label;
    #element;
    #errorElement;
    #validators = [];

    constructor(label, element, errorElement) {
        this.#label = label;
        this.#element = element;
        this.#errorElement = errorElement;
        this.#element.addEventListener("focusout", () => this.validate());
    }

    /**
     * Calls validation on each validator on this field.
     * @returns {boolean} true if this field passes all its validators.
     */
    validate() {
        const firstError = this.#validators
            .find(v => !v.passes(this.#element.value))
            ?.errorMessage;
        this.#errorElement.innerText = firstError ?? "";
        return !firstError;
    }

    /**
     * Adds a validation rule that this field's text be within the specified range.
     * @param {number} min minimum length of this text field.
     * @param {number} max maximum length of this text field.
     * @returns {Field} this, for chaining.
     */
    length(min, max) {
        this.#validators.push(new Validator(
            value => min <= value.length && value.length <= max,
            `${this.#label} must be between ${min} and ${max} characters.`
        ));
        return this;
    }

    /**
     * Adds a validation rule that this field's text match a regex.
     * @param {RegExp} regex the regex to check this field's text against.
     * @param {string} errorMessage the error message to show when this field's value does not pass the regex.
     * @returns {Field} this, for chaining.
     */
    matches(regex, errorMessage) {
        this.#validators.push(new Validator(
            value => regex.test(value), 
            errorMessage
        ));
        return this;
    }
}

class Validator {
    #passes;
    #errorMessage;

    constructor(passes, errorMessage) {
        this.#passes = passes;
        this.#errorMessage = errorMessage;
    }

    get errorMessage() { return this.#errorMessage; }

    passes(value) {
        return this.#passes(value);
    }
}

function _find(selector) {
    const element = document.querySelector(selector);
    if (!element) {
        throw new Error(`Element not found with selector ${selector}`);
    }
    return element;
}