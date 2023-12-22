texture gPaintjobTexture;
 
technique paintjob
{
        pass P0
        {
                Texture[0] = gPaintjobTexture;
        }
}
 