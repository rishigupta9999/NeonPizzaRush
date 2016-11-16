//
//  Shader.fsh
//  SparkParticles
//
//  Created by Rishi Gupta on 6/20/14.
//  Copyright (c) 2014 Neon Games LLC. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
