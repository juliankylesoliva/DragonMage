using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MagicBlast : MonoBehaviour
{
    /* COMPONENTS */
    Rigidbody2D rb2d;

    /* EDITOR VARIABLES */
    [SerializeField] float verticalLaunchSpeed = 1f;
    [SerializeField] float horizontalLaunchSpeed = 2f;

    void Awake()
    {
        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
    }

    public void Setup(bool isGoingRight = true)
    {
        rb2d.velocity = new Vector2((isGoingRight ? horizontalLaunchSpeed : -horizontalLaunchSpeed), verticalLaunchSpeed);
    }
}
