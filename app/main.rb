PLAYER_W = 100
PLAYER_H = 80
SPEED = 12

def tick(args)
  args.state.player ||= {
    x: 120,
    y: 280,
    w: PLAYER_W,
    h: PLAYER_H,
    speed: SPEED,
    path: 'sprites/misc/dragon-0.png',
  }
  args.state.fireballs ||= []

  handle_movement(args)
  stay_in_bounds(args)
  spit_fire(args)

  args.outputs.sprites << [args.state.player, args.state.fireballs]
end

def spit_fire(args)
  if args.inputs.keyboard.key_down.z || args.inputs.keyboard.key_down.j || args.inputs.controller_one.key_down.a
    args.state.fireballs << {
      x: args.state.player.x + args.state.player.w,
      y: args.state.player.y + (args.state.player.h/6),
      w: 32,
      h: 32,
      path: 'sprites/misc/fireball.png',
    }
  end

  args.state.fireballs.each do |fireball|
    fireball.x += args.state.player.speed + 2
  end
end

def handle_movement(args)
  if args.inputs.left
    args.state.player.x -= args.state.player.speed
  elsif args.inputs.right
    args.state.player.x += args.state.player.speed
  end

  if args.inputs.up
    args.state.player.y += args.state.player.speed
  elsif args.inputs.down
    args.state.player.y -= args.state.player.speed
  end
end

def stay_in_bounds(args)
  if args.state.player.x +  args.state.player.w > args.grid.w
    args.state.player.x = args.grid.w - args.state.player.w
  end

  if args.state.player.x < 0
    args.state.player.x = 0
  end

  if args.state.player.y + args.state.player.h > args.grid.h
    args.state.player.y = args.grid.h - args.state.player.h
  end

  if args.state.player.y < 0
    args.state.player.y = 0
  end
end
