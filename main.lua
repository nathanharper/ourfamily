-- TODO: better separation of data and logic.
-- local MODE = "static"
local MODE = "dynamic"
local nathan,ernie,sansa={},{},{}
local world, mouse_collisions -- the "World" object and a collection of objects colliding with the mouse
local mouse_joint, clicked_fixture

-- "Shallow" table copy; non-recursive
local function cpy(t)
  local c = {}
  for k,v in pairs(t) do
    c[k] = v
  end
  return c
end

local function load_nathan()
  local clickable = { -- user data table for all clickable objects
    clickable = true,
    table     = nathan
  }

  nathan.images = {}
  nathan.images.head = love.graphics.newImage "assets/nhead.png"
  nathan.images.body = love.graphics.newImage "assets/nbody.png"
  nathan.images.leg = love.graphics.newImage "assets/nleg.png"
  nathan.images.arm = love.graphics.newImage "assets/narm.png"

  nathan.sounds = {}
  nathan.sounds.click = {}
  nathan.sounds.release = {}
  nathan.sounds.click[1] = love.audio.newSource("assets/hey-chelsea.wav", "static")
  nathan.sounds.release[1] = love.audio.newSource("assets/i-love-you.wav", "static")

  nathan.head = {}
    nathan.head.body = love.physics.newBody(world, 650/2, 650/2, MODE)
    nathan.head.shape = love.physics.newCircleShape(36) --the ball's shape has a radius of 20
    nathan.head.fixture = love.physics.newFixture(nathan.head.body, nathan.head.shape, 1)
    nathan.head.fixture:setRestitution(0.9) --let the ball bounce
    nathan.head.fixture:setUserData(cpy(clickable))

  nathan.bod = {}
    nathan.bod.body = love.physics.newBody(world, 650/2+20, 650/2+40+70, MODE)
    nathan.bod.shape = love.physics.newRectangleShape(0,0, 60, 140)
    nathan.bod.fixture = love.physics.newFixture(nathan.bod.body, nathan.bod.shape, 1)
    nathan.bod.fixture:setRestitution(0.9)
    nathan.bod.fixture:setUserData(cpy(clickable))
  love.physics.newRevoluteJoint(nathan.head.body, nathan.bod.body, 650/2+20, 650/2+40, true)

  nathan.rarm = {}
    nathan.rarm.body = love.physics.newBody(world, 650/2+50+35, 650/2+40+30, MODE)
    nathan.rarm.shape = love.physics.newRectangleShape(0,0, 70, 20)
    nathan.rarm.fixture = love.physics.newFixture(nathan.rarm.body, nathan.rarm.shape, 1)
    nathan.rarm.fixture:setRestitution(0.9)
    nathan.rarm.fixture:setUserData(cpy(clickable))
  love.physics.newRevoluteJoint(nathan.bod.body, nathan.rarm.body, 650/2+50, 650/2+40+30, false)

  nathan.larm = {}
    nathan.larm.body = love.physics.newBody(world, 650/2+20-65, 650/2+40+30, MODE)
    nathan.larm.shape = love.physics.newRectangleShape(0,0, 70, 20)
    nathan.larm.fixture = love.physics.newFixture(nathan.larm.body, nathan.larm.shape, 1)
    nathan.larm.fixture:setRestitution(0.9)
    nathan.larm.fixture:setUserData(cpy(clickable))
  love.physics.newRevoluteJoint(nathan.bod.body, nathan.larm.body, 650/2-10, 650/2+40+30, false)

  local xo = 15
  local yo = 20
  nathan.rleg = {}
    nathan.rleg.body = love.physics.newBody(world, 650/2+20-xo, 650/2+180+yo, MODE)
    nathan.rleg.shape = love.physics.newRectangleShape(0,0, 20, 70)
    nathan.rleg.fixture = love.physics.newFixture(nathan.rleg.body, nathan.rleg.shape, 1)
    nathan.rleg.fixture:setRestitution(0.9)
    nathan.rleg.fixture:setUserData(cpy(clickable))
  love.physics.newRevoluteJoint(nathan.bod.body, nathan.rleg.body, 650/2+20-xo, 650/2+145+yo, false)

  nathan.lleg = {}
    nathan.lleg.body = love.physics.newBody(world, 650/2+20+xo, 650/2+180+yo, MODE)
    nathan.lleg.shape = love.physics.newRectangleShape(0,0, 20, 70)
    nathan.lleg.fixture = love.physics.newFixture(nathan.lleg.body, nathan.lleg.shape, 1)
    nathan.lleg.fixture:setRestitution(0.9)
    nathan.lleg.fixture:setUserData(cpy(clickable))
  love.physics.newRevoluteJoint(nathan.bod.body, nathan.lleg.body, 650/2+20+xo, 650/2+145+yo, false)
end

local function load_cats()
  local sansa_mt = {
    clickable = true,
    table     = sansa
  }
  local ernie_mt = {
    clickable = true,
    table     = ernie
  }

  sansa.image = love.graphics.newImage "assets/sansa.png"
  sansa.sounds = {}
  sansa.sounds.click = {}
  sansa.sounds.release = {}
  sansa.sounds.click[1] = love.audio.newSource("assets/brup.wav", "static")
  sansa.sounds.release[1] = love.audio.newSource("assets/breeow.wav", "static")

  sansa.body = love.physics.newBody(world, 400, 400, MODE)
  sansa.shape = love.physics.newRectangleShape(0,0,52,100)
  sansa.fixture = love.physics.newFixture(sansa.body, sansa.shape, 1)
  sansa.fixture:setRestitution(1)
  sansa.fixture:setUserData(sansa_mt)

  ernie.image = love.graphics.newImage "assets/ernie.png"
  ernie.sounds = {}
  ernie.sounds.click = {}
  ernie.sounds.release = {}
  ernie.sounds.click[1] = love.audio.newSource("assets/hiss.wav", "static")
  ernie.sounds.release[1] = love.audio.newSource("assets/rasp.wav", "static")

  ernie.body = love.physics.newBody(world, 60, 60, MODE)
  ernie.shape = love.physics.newRectangleShape(0,0,100,150)
  ernie.fixture = love.physics.newFixture(ernie.body, ernie.shape, 1)
  ernie.fixture:setRestitution(0.9)
  ernie.fixture:setUserData(ernie_mt)
end

local function draw_nathan()
  -- local origin_offset = nathan.head.shape:getRadius()
  love.graphics.draw(nathan.images.head, 
                     nathan.head.body:getX(), 
                     nathan.head.body:getY(), 
                     nathan.head.body:getAngle(),
                     1, 1, -- scale factor
                     40,40)
  love.graphics.draw(nathan.images.body,
                     nathan.bod.body:getX(), 
                     nathan.bod.body:getY(), 
                     nathan.bod.body:getAngle(),
                     1, 1, -- scale factor
                     30, 70)
  love.graphics.draw(nathan.images.arm,
                     nathan.larm.body:getX(), 
                     nathan.larm.body:getY(), 
                     nathan.larm.body:getAngle(),
                     -1, 1, -- scale factor
                     35, 10)
  love.graphics.draw(nathan.images.arm,
                     nathan.rarm.body:getX(), 
                     nathan.rarm.body:getY(), 
                     nathan.rarm.body:getAngle(),
                     1, 1, -- scale factor
                     35, 10)
  love.graphics.draw(nathan.images.leg,
                     nathan.lleg.body:getX(), 
                     nathan.lleg.body:getY(), 
                     nathan.lleg.body:getAngle(),
                     1, 1, -- scale factor
                     10, 35)
  love.graphics.draw(nathan.images.leg,
                     nathan.rleg.body:getX(), 
                     nathan.rleg.body:getY(), 
                     nathan.rleg.body:getAngle(),
                     1, 1, -- scale factor
                     10, 35)
end

local function draw_cats()
  love.graphics.draw(sansa.image,
                     sansa.body:getX(),
                     sansa.body:getY(),
                     sansa.body:getAngle(),
                     1,1,
                     26,50)
  love.graphics.draw(ernie.image,
                     ernie.body:getX(),
                     ernie.body:getY(),
                     ernie.body:getAngle(),
                     1,1,
                     50,75)
end

function love.load()
  math.randomseed(os.time())
  love.physics.setMeter(64) --the height of a meter our worlds will be 64px
  world = love.physics.newWorld(0, 9.81*64, true)

  mouse_collisions = {}

  load_nathan()
  load_cats()

  objects = {} -- table to hold all our physical objects

  --let's create the ground
  local ground_width = 50
  objects.ground = {}
    objects.ground.body = love.physics.newBody(world, 400, 700-ground_width/2)
    objects.ground.shape = love.physics.newRectangleShape(800, ground_width)
    objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape);
  objects.ceil = {}
    objects.ceil.body = love.physics.newBody(world, 400, ground_width/2)
    objects.ceil.shape = love.physics.newRectangleShape(800, ground_width)
    objects.ceil.fixture = love.physics.newFixture(objects.ceil.body, objects.ceil.shape);
  objects.lwall = {}
    objects.lwall.body = love.physics.newBody(world, ground_width/2, 350)
    objects.lwall.shape = love.physics.newRectangleShape(ground_width, 700-ground_width)
    objects.lwall.fixture = love.physics.newFixture(objects.lwall.body, objects.lwall.shape);
  objects.rwall = {}
    objects.rwall.body = love.physics.newBody(world, 800-ground_width/2, 350)
    objects.rwall.shape = love.physics.newRectangleShape(ground_width, 700-ground_width)
    objects.rwall.fixture = love.physics.newFixture(objects.rwall.body, objects.rwall.shape);

  --let's create a couple blocks to play around with
  objects.block1 = {}
    objects.block1.body = love.physics.newBody(world, 200, 550, "dynamic")
    objects.block1.shape = love.physics.newRectangleShape(0, 0, 50, 100)
    objects.block1.fixture = love.physics.newFixture(objects.block1.body, objects.block1.shape, 5)

  objects.block2 = {}
    objects.block2.body = love.physics.newBody(world, 200, 400, "dynamic")
    objects.block2.shape = love.physics.newRectangleShape(0, 0, 100, 50)
    objects.block2.fixture = love.physics.newFixture(objects.block2.body, objects.block2.shape, 2)

  objects.mouse = {}
    objects.mouse.body = love.physics.newBody(world, 0, 0, "kinematic")
    objects.mouse.shape = love.physics.newRectangleShape(0, 0, 5, 5)
    objects.mouse.fixture = love.physics.newFixture(objects.mouse.body, objects.mouse.shape, 1)
    objects.mouse.fixture:setSensor(true) -- prevent collisions


  --[================================================================[
     Here we set up callbacks for start and end of mouse collision.
     The LOVE documentation is wrong. The typical order of events is:
    
     1. Collision Start callback is triggered.
     2. While object is colliding, the pre-solve callback is
        continuously triggered. This is where a collision can
        be disabled.
     3. Collision post-solve is triggered, unless the collision
        was previously disabled in the pre-solve callback.
     4. Collision end callback is triggered when bodies are
        no longer in contact.
  --]================================================================]
  local beginContact = function(a, b, coll)
    local object = (a == objects.mouse.fixture and b) 
                or (b == objects.mouse.fixture and a) 
                or false
    if not object then return end
    local ud = object:getUserData()
    if ud and ud.clickable then
      mouse_collisions[ud] = object
    end
  end

  local endContact = function(a, b, coll)
    local ud
    if a == objects.mouse.fixture then
      ud = b:getUserData()
    elseif b == objects.mouse.fixture then
      ud = a:getUserData()
    else 
      return 
    end

    if ud and mouse_collisions[ud] then
      mouse_collisions[ud] = nil
    end
  end

  world:setCallbacks(beginContact, endContact, nil, nil)

  --initial graphics setup
  love.graphics.setBackgroundColor(104, 136, 248) --set the background color to a nice blue
  love.graphics.setColorMode('replace')
end

function love.mousepressed(x, y, button)
  if button ~= "l" then return end
  for _,v in pairs(mouse_collisions) do
    local table = v:getUserData().table
    clicked_fixture = v
    mouse_joint = love.physics.newMouseJoint(v:getBody(), x, y)
    if table.sounds then
      local randy = math.random(#table.sounds.click)
      love.audio.play(table.sounds.click[randy])
    end
    return
  end
end

function love.mousereleased(x, y, button)
  if button ~= "l" then return end
  if mouse_joint then 
    local table = clicked_fixture:getUserData().table
    if table.sounds then
      local randy = math.random(#table.sounds.release)
      love.audio.play(table.sounds.release[randy])
    end
    mouse_joint:destroy()
    mouse_joint = nil; clicked_fixture = nil
  end
end

function love.update(dt)
  -- update mouse stuff
  objects.mouse.body:setPosition(love.mouse.getPosition())
  if mouse_joint then 
    mouse_joint:setTarget(love.mouse.getPosition())
  end
  world:update(dt)
end

function love.draw()
  love.graphics.setColor(72, 160, 14)
  love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints()))
  love.graphics.polygon("fill", objects.lwall.body:getWorldPoints(objects.lwall.shape:getPoints()))
  love.graphics.polygon("fill", objects.rwall.body:getWorldPoints(objects.rwall.shape:getPoints()))
  love.graphics.polygon("fill", objects.ceil.body:getWorldPoints(objects.ceil.shape:getPoints()))

  draw_nathan()
  draw_cats()

  love.graphics.setColor(50, 50, 50) -- set the drawing color to grey for the blocks
  love.graphics.polygon("fill", objects.block1.body:getWorldPoints(objects.block1.shape:getPoints()))
  love.graphics.polygon("fill", objects.block2.body:getWorldPoints(objects.block2.shape:getPoints()))
end
