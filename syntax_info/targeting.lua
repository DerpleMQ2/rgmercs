local functions_info = {
    functions = {
        {
            name = "Targeting:GetTarget",
            description = "Gets the current target.",
            parameters = {},
            return_type = "table or nil",
        },
        {
            name = "Targeting:SetTarget",
            description = "Sets the current target.",
            parameters = {
                {
                    name = "target",
                    type = "table",
                    description = "The target to set.",
                },
            },
            return_type = "nil",
        },
        {
            name = "Targeting:ClearTarget",
            description = "Clears the current target.",
            parameters = {},
            return_type = "nil",
        },
        {
            name = "Targeting:IsTargetValid",
            description = "Checks if the current target is valid.",
            parameters = {},
            return_type = "boolean",
        },
        {
            name = "Targeting:FindTarget",
            description = "Finds a target based on specific criteria.",
            parameters = {
                {
                    name = "criteria",
                    type = "table",
                    description = "The criteria to use for finding the target.",
                },
            },
            return_type = "table or nil",
        },
        {
            name = "Targeting:Assist",
            description = "Assists another character in targeting.",
            parameters = {
                {
                    name = "character",
                    type = "string",
                    description = "The character to assist.",
                },
            },
            return_type = "nil",
        },
        {
            name = "Targeting:MarkTarget",
            description = "Marks the current target.",
            parameters = {
                {
                    name = "markType",
                    type = "string",
                    description = "The type of mark to apply.",
                },
            },
            return_type = "nil",
        },
        {
            name = "Targeting:UnmarkTarget",
            description = "Unmarks the current target.",
            parameters = {},
            return_type = "nil",
        },
        {
            name = "Targeting:TargetNearestNPC",
            description = "Targets the nearest NPC.",
            parameters = {},
            return_type = "nil",
        },
        {
            name = "Targeting:TargetNearestPC",
            description = "Targets the nearest PC.",
            parameters = {},
            return_type = "nil",
        },
        {
            name = "Targeting:TargetByName",
            description = "Targets an entity by name.",
            parameters = {
                {
                    name = "name",
                    type = "string",
                    description = "The name of the entity to target.",
                },
            },
            return_type = "nil",
        },
    },
}

return functions_info
