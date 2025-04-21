local functions_info = {
    functions = {
        {
            name = "IsModeActive",
            description = "Checks if a specific mode is active.",
            parameters = {
                {
                    name = "mode",
                    type = "string",
                    description = "The mode to check.",
                },
            },
            return_type = "boolean",
        },
        {
            name = "IsTanking",
            description = "Checks if the character is tanking.",
            parameters = {},
            return_type = "boolean",
        },
        {
            name = "IsHealing",
            description = "Checks if the character is healing.",
            parameters = {},
            return_type = "boolean",
        },
        {
            name = "IsRezing",
            description = "Checks if the character is resurrecting.",
            parameters = {},
            return_type = "boolean",
        },
        {
            name = "IsCharming",
            description = "Checks if the character is charming.",
            parameters = {},
            return_type = "boolean",
        },
        {
            name = "CanMez",
            description = "Checks if the character can use the Mez ability.",
            parameters = {},
            return_type = "boolean",
        },
        {
            name = "CanCharm",
            description = "Checks if the character can use the Charm ability.",
            parameters = {},
            return_type = "boolean",
        },
        {
            name = "GetTheme",
            description = "Gets the current theme based on the class mode.",
            parameters = {},
            return_type = "string or nil",
        },
        {
            name = "GetClassConfig",
            description = "return_types the class configuration.",
            parameters = {},
            return_type = "table",
        },
        {
            name = "GetRotations",
            description = "Gets the valid rotations based on load conditions.",
            parameters = {},
            return_type = "table",
        },
        {
            name = "LoadClassConfig",
            description = "Loads the class configuration.",
            parameters = {},
            return_type = "nil",
        },
        {
            name = "SaveClassConfig",
            description = "Saves the class configuration.",
            parameters = {},
            return_type = "nil",
        },
        {
            name = "ResetClassConfig",
            description = "Resets the class configuration to default values.",
            parameters = {},
            return_type = "nil",
        },
        {
            name = "UpdateClassConfig",
            description = "Updates the class configuration with new values.",
            parameters = {
                {
                    name = "newConfig",
                    type = "table",
                    description = "The new configuration values.",
                },
            },
            return_type = "nil",
        },
        {
            name = "CheckLoadConditions",
            description = "Checks if the load conditions for a rotation are met.",
            parameters = {
                {
                    name = "conditions",
                    type = "table",
                    description = "The load conditions to check.",
                },
            },
            return_type = "boolean",
        },
        {
            name = "SafeCallFunc",
            description = "Safely calls a function with the provided arguments.",
            parameters = {
                {
                    name = "funcName",
                    type = "string",
                    description = "The name of the function to call.",
                },
                {
                    name = "args",
                    type = "table",
                    description = "The arguments to pass to the function.",
                },
            },
            return_type = "any",
        },
    },
}

return functions_info
