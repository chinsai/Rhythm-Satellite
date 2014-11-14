//
//  Character.m
//  Rhythm Satellite
//
//  Created by Kiron on 2014/10/19.
//  Copyright (c) 2014年 Kiron. All rights reserved.
//

#import "Character.h"

@implementation Character

-(id)initWithLevel: (uint8_t)level withExp:(uint32_t)exp withHp:(uint32_t)hp withMaxHp:(uint32_t)maxHp withAtt:(uint32_t)att withDef:(uint32_t)def withMoney:(uint32_t)money withPlayer:(Player*)player{
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Nori.Nod"];
    SKTexture *texture = [atlas textureNamed:@"nori_nod_0001"];
    self = [super initWithTexture:texture];
    
    _level = level;
    _exp = exp;
    _hp = hp;
    _maxHp = maxHp;
    _att = att;
    _def = def;
    _money = money;
    _player = player;
    
    
    return self;
}

- (void)reset{
    ;
}

- (void)takeCommand:(CommandType)command{
    ;
}

- (uint32_t)attack{
    ;
    return _att;
}
- (void)defendFor:(uint32_t)damage{
    ;
}

- (void)charge{
    
}

@end
