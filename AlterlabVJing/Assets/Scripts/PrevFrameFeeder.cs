using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PrevFrameFeeder : MonoBehaviour {

	public Material m_material = null;
	public string m_textureName = "";
	public int TextureSize = 1024;

	RenderTexture m_pastTexture = null;
	RenderTexture m_pastTexture1 = null;

	public Camera m_camera = null;


	public Material m_textureGraber = null;


	void Start () {

		m_pastTexture = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
		m_pastTexture1 = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
		m_material.SetTexture(m_textureName, m_pastTexture1);
		m_textureGraber.SetTexture("_MainTex", m_pastTexture1);
		m_camera.targetTexture = m_pastTexture;

	}
	
	void Update () {

		Graphics.Blit(m_pastTexture, m_pastTexture1);
	}
}
