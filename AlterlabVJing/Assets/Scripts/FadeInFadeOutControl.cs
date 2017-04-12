using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FadeInFadeOutControl : MonoBehaviour {

	[SerializeField]
	KeyCode m_activator = KeyCode.A;

	[SerializeField]
	float m_speed = .1f;

	float m_timer = 0f;

	bool m_isDisplay = false;

	Material m_mainMaterial;

	void Start () {
		var renderer = GetComponent<Renderer>();
		m_mainMaterial = new Material(renderer.material);
		renderer.material = m_mainMaterial;
		ApplyColor();
	}
	


	void Update () {
		if (Input.GetKeyDown(m_activator))
		{
			m_isDisplay = !m_isDisplay;
		}

		if ((m_isDisplay && m_timer < 1f) || (!m_isDisplay && m_timer > 0f))
		{
			m_timer += (m_isDisplay ? 1f : -1f) * Time.deltaTime * m_speed;
			ApplyColor();
		}	
	}

	void ApplyColor()
	{
		float p = Mathf.Clamp01(m_timer);
		var color = Color.white;
		color.a = p;
		m_mainMaterial.color = color;

	}
}
