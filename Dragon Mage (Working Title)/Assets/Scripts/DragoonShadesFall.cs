using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DragoonShadesFall : MonoBehaviour
{
    Rigidbody2D rb2d;
    SpriteRenderer spriteRenderer;

    [SerializeField] float baseVerticalKnockback = 3f;
    [SerializeField] float destroyCameraDistance = 25f;

    void Awake()
    {
        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
        spriteRenderer = this.gameObject.GetComponent<SpriteRenderer>();
    }

    void Update()
    {
        CheckCameraDistance();
    }

    public void Setup(Vector2 velocity, bool flipX)
    {
        rb2d.velocity = (Vector2.up * baseVerticalKnockback);
        spriteRenderer.flipX = flipX;
    }

    private void CheckCameraDistance()
    {
        Vector3 cameraPosition = Camera.main.transform.position;
        cameraPosition.z = 0f;

        Vector3 thisPosition = this.transform.position;

        if (Vector3.Distance(cameraPosition, thisPosition) >= destroyCameraDistance)
        {
            GameObject.Destroy(this.gameObject);
        }
    }
}
