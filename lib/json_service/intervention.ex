defmodule JsonService.Intervention do
  defstruct id: nil,
    from: nil,
    to: nil,
    type: nil,
    subtype: nil,
    comment: nil

  def new(from, to, type, subtype, comment) do
    %__MODULE__{
      id: UUID.uuid4(),
      from: from,
      to: to,
      type: type,
      subtype: subtype,
      comment: comment
    }
  end

  def new(id, from, to, type, subtype, comment) do
    %__MODULE__{
      id: to_string(id),
      from: from,
      to: to,
      type: type,
      subtype: subtype,
      comment: comment
    }
  end
end