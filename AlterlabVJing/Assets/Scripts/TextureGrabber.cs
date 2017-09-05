using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Renderer))]
public class TextureGrabber : MonoBehaviour {

    public SoundToTexture m_textureSource = null;
    public string m_propertyTarget = "_MainTex";
    
    void Start () {
        var renderer = GetComponent<Renderer>();
        renderer.material.SetTexture(m_propertyTarget, m_textureSource.m_pastTexture1);
	}
	
}
