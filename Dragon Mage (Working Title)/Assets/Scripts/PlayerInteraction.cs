using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IInteractable
{
    public void Interact(PlayerCtrl playerSrc);
}

public class PlayerInteraction : MonoBehaviour
{
    private PlayerCtrl player;
    private IInteractable interactableRef = null;

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    void Update()
    {
        if (player.interactButtonDown && interactableRef != null)
        {
            interactableRef.Interact(player);
        }
    }

    public void SetInteractableRef(IInteractable interactable)
    {
        interactableRef = interactable;
    }

    public void UnsetInteractableRef(IInteractable interactable)
    {
        if (interactableRef != null && interactableRef == interactable)
        {
            interactableRef = null;
        }
    }
}
