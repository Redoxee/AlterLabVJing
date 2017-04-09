using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BGAlphaController : MonoBehaviour {

	Material m_materialRef;

	[SerializeField]
	float m_fadeDuration = 1f;

	bool m_isFadeOut = true;

	float m_timer = 1f;

	Texture2D m_texture = null;

	void Start () {
		var renderer = GetComponentInChildren<Renderer>();
		m_materialRef = new Material(renderer.material);
		renderer.material = m_materialRef;

		if (m_texture != null)
			m_materialRef.mainTexture = m_texture;
	}

	public void SetTexture(Texture2D tex)
	{
		m_texture = tex;
		if(m_materialRef != null)
			m_materialRef.mainTexture = tex;
	}

	public void SetAlpha(float alpha)
	{
		alpha = Mathf.Clamp01(alpha);
		m_materialRef.color = new Color(1f, 1f, 1f, alpha);
	}

	public void SetDisplay(bool display)
	{
		m_isFadeOut = !display;
	}

	void Update () {
		if ((m_isFadeOut && m_timer <= 0f) || (!m_isFadeOut && m_timer >= m_fadeDuration))
			return;
		m_timer += Time.deltaTime * (m_isFadeOut ? -1 : 1);
		var progression = Mathf.Clamp01(m_timer / m_fadeDuration);
		SetAlpha(progression);
	}
}
