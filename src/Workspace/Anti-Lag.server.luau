Debris = game.Debris
MaxDebris = game.Debris.MaxItems

if (Debris.MaxItems > 9999999999)then
    Debris.MaxItems = MaxDebris*9999999999
end