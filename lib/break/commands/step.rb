command :step, short: :s do
  TracePoint.trace(:line, :call, :return, :class, :end) do |trace|
    next if Filter.internal?(trace.path)

    case trace.event
    when :call, :class
      trace.disable

      current.context!(*current.context.frames, trace.binding)
    when :return, :end
      current.context.frames.pop
      current.context.depth -= 1
    when :line
      next if current.context.depth.positive?

      trace.disable

      current.context!(*current.context.frames[0...-1], trace.binding)
    end
  end

  current.leave
end
