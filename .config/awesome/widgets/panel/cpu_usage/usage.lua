local usage = {}

usage.tracked_cores = {}

function usage.calculate_core_usage(core_num, jiffies)
    -- https://stackoverflow.com/a/3017438
    local last_state = usage.tracked_cores[core_num] or {
        total_jiffies = 0,
        work_jiffies = 0,
    }

    local state = {
        total_jiffies = 0,
        work_jiffies = 0,
    }

    local index = 1
    
    for i = 1, #jiffies do
        local jiffie = jiffies[i]
        
        state.total_jiffies = state.total_jiffies + jiffie

        if index <= 3 then
            state.work_jiffies = state.work_jiffies + jiffie
        end

        index = index + 1
    end

    local total_over_period = state.total_jiffies - last_state.total_jiffies
    local work_over_period = state.work_jiffies - last_state.work_jiffies

    local usage_pcnt = work_over_period / total_over_period * 100

    usage.tracked_cores[core_num] = state
    return usage_pcnt
end

return usage