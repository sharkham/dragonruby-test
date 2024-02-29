PLAYER_W = 100
PLAYER_H = 80
SPEED = 12

def tick args
  args.state.player_x ||= 120
  args.state.player_y ||= 280

  handle_movement(args)
  stay_in_bounds(args)

  args.outputs.sprites << [args.state.player_x, args.state.player_y, PLAYER_W, PLAYER_H, 'sprites/misc/dragon-0.png']
end

def handle_movement(args)
  if args.inputs.left
    args.state.player_x -= SPEED
  elsif args.inputs.right
    args.state.player_x += SPEED
  end

  if args.inputs.up
    args.state.player_y += SPEED
  elsif args.inputs.down
    args.state.player_y -= SPEED
  end
end

def stay_in_bounds(args)
  if args.state.player_x +  PLAYER_W > args.grid.w
    args.state.player_x = args.grid.w - PLAYER_W
  end

  if args.state.player_x < 0
    args.state.player_x = 0
  end

  if args.state.player_y + PLAYER_H > args.grid.h
    args.state.player_y = args.grid.h - PLAYER_H
  end

  if args.state.player_y < 0
    args.state.player_y = 0
  end
end