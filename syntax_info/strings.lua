local functions_info = {
    functions = {
        {
            name = "Strings:Trim",
            description = "Trims whitespace from both ends of the string.",
            parameters = {
                {
                    name = "s",
                    type = "string",
                    description = "The string to trim.",
                },
            },
            return_type = "string",
        },
        {
            name = "Strings:Split",
            description = "Splits a string into a table based on a delimiter.",
            parameters = {
                {
                    name = "s",
                    type = "string",
                    description = "The string to split.",
                },
                {
                    name = "delimiter",
                    type = "string",
                    description = "The delimiter to split the string by.",
                },
            },
            return_type = "table",
        },
        {
            name = "Strings:StartsWith",
            description = "Checks if the string starts with the given prefix.",
            parameters = {
                {
                    name = "s",
                    type = "string",
                    description = "The string to check.",
                },
                {
                    name = "prefix",
                    type = "string",
                    description = "The prefix to check for.",
                },
            },
            return_type = "boolean",
        },
        {
            name = "Strings:EndsWith",
            description = "Checks if the string ends with the given suffix.",
            parameters = {
                {
                    name = "s",
                    type = "string",
                    description = "The string to check.",
                },
                {
                    name = "suffix",
                    type = "string",
                    description = "The suffix to check for.",
                },
            },
            return_type = "boolean",
        },
        {
            name = "Strings:Contains",
            description = "Checks if the string contains the given substring.",
            parameters = {
                {
                    name = "s",
                    type = "string",
                    description = "The string to check.",
                },
                {
                    name = "substring",
                    type = "string",
                    description = "The substring to check for.",
                },
            },
            return_type = "boolean",
        },
        {
            name = "Strings:ToUpper",
            description = "Converts the string to uppercase.",
            parameters = {
                {
                    name = "s",
                    type = "string",
                    description = "The string to convert.",
                },
            },
            return_type = "string",
        },
        {
            name = "Strings:ToLower",
            description = "Converts the string to lowercase.",
            parameters = {
                {
                    name = "s",
                    type = "string",
                    description = "The string to convert.",
                },
            },
            return_type = "string",
        },
        {
            name = "Strings:Capitalize",
            description = "Capitalizes the first letter of the string.",
            parameters = {
                {
                    name = "s",
                    type = "string",
                    description = "The string to capitalize.",
                },
            },
            return_type = "string",
        },
    },
}

return functions_info
