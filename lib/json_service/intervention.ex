defmodule JsonService.Intervention do
  defstruct id: nil,
    from: nil,
    to: nil,
    type: nil,
    comment: nil

  def new(from, to, type, comment) do
    %__MODULE__{
      id: UUID.uuid4(),
      from: from,
      to: to,
      type: type,
      comment: comment
    }
  end

  def new(id, from, to, type, comment) do
    %__MODULE__{
      id: id,
      from: from,
      to: to,
      type: type,
      comment: comment
    }
  end
end