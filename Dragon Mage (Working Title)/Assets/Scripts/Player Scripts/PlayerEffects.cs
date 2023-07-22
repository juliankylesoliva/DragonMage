using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerEffects : MonoBehaviour
{
    PlayerCtrl player;

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    public void FootstepSound()
    {
        SoundFactory.SpawnSound(player.form.currentMode == CharacterMode.MAGE ? "jump_magli_landing" : "jump_draelyn_landing", player.collisions.groundCheckObj.position, 0.75f);
    }

    public void FootstepDust()
    {
        GameObject tempObj = EffectFactory.SpawnEffect("WalkingDust", player.collisions.GetSimpleGroundPoint());
        SpriteRenderer tempSprite = tempObj.GetComponent<SpriteRenderer>();
        tempSprite.flipX = !player.movement.isFacingRight;
    }

    public void TurnaroundSpark()
    {
        SoundFactory.SpawnSound(player.form.currentMode == CharacterMode.MAGE ? "movement_magli_turnaround" : "movement_draelyn_turnaround", player.collisions.GetSimpleGroundPoint(), 0.75f);
        GameObject tempObj = EffectFactory.SpawnEffect("TurnaroundSpark", player.collisions.GetSimpleGroundPoint());
        SpriteRenderer tempSprite = tempObj.GetComponent<SpriteRenderer>();
        tempSprite.flipX = (player.movement.GetFacingValue() < 0f);
    }

    public void HeadbonkEffect()
    {
        SoundFactory.SpawnSound(player.form.currentMode == CharacterMode.MAGE ? "jump_magli_headbonk" : "jump_draelyn_headbonk", player.collisions.groundCheckObj.position, 0.75f);
        GameObject tempObj = EffectFactory.SpawnEffect("HeadbonkEffect", player.collisions.GetSimpleCeilingPoint());
        tempObj.transform.up = player.collisions.GetCeilingNormal();
    }
}
