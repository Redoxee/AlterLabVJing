using System;
using System.Collections.Generic;
using UnityEngine;

public class SoundToTexture : MonoBehaviour {
	[Header("Sound grabbing")]
	public GameObject m_soundQuad = null;
	public Camera m_firstCamera = null;
	public Material m_soundProcessingMaterial = null;
	public MicGrabber m_soundFeed = null;
	public int TextureSize = 1024;

	Texture2D m_soundTexture = null;
	RenderTexture m_pastTexture = null;
	RenderTexture m_pastTexture1 = null;


	[Header("First pass")]
	public Material m_firstPassMaterial = null;
	public GameObject m_firstOutQuad = null;
	public Camera m_firstOutCamera = null;

	private void Start()
	{
		m_pastTexture = new RenderTexture(TextureSize, TextureSize, 0, RenderTextureFormat.RFloat);
		m_pastTexture1 = new RenderTexture(TextureSize, TextureSize, 0, RenderTextureFormat.RFloat);
		//m_pastTexture.wrapMode = TextureWrapMode.Clamp;
		//m_pastTexture1.wrapMode = TextureWrapMode.Clamp;

		m_soundTexture = new Texture2D(m_soundFeed.m_extractedData.Length, 1, TextureFormat.RFloat, false);
		m_firstCamera.targetTexture = m_pastTexture;
		var size = m_firstCamera.orthographicSize;
		m_soundQuad.transform.localScale = new Vector3(2,2,2) * size;
		m_soundProcessingMaterial.SetFloat("_Size", m_soundFeed.m_extractedData.Length);
		m_soundProcessingMaterial.SetTexture("_PastTex", m_pastTexture1);
		m_soundProcessingMaterial.SetTexture("_InputSound", m_soundTexture);


		size = m_firstOutCamera.orthographicSize;
		var ratio = (float)Screen.width / (float)Screen.height;
		m_firstOutQuad.transform.localScale = new Vector3(ratio, 1, 1) * size * 2;
		m_firstPassMaterial.mainTexture = m_pastTexture1;
		m_firstPassMaterial.SetVector("_Resolution", new Vector4(Screen.width,Screen.height,ratio,0.0f));
	}

	void Update () {
		var data = m_soundFeed.m_extractedData;
		
		for (int i = 0; i < data.Length; ++i)
		{
			m_soundTexture.SetPixel(i, 0, new Color(data[i], 0, 0));
		}
		m_soundTexture.Apply();
		Graphics.Blit(m_pastTexture, m_pastTexture1);

	}
}
