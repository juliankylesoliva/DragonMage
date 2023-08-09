using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerEffects : MonoBehaviour
{
    PlayerCtrl player;

    [SerializeField] float droppedFragmentsSpeed = 5f;

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

    public void DroppedFragmentsEffect()
    {
        int droppedMageFragments = MedalFragment.droppedMageFragments;
        int droppedDragonFragments = MedalFragment.droppedDragonFragments;
        int totalDroppedFragments = (droppedMageFragments + droppedDragonFragments);

        for (int i = 0; i < totalDroppedFragments; ++i)
        {
            Vector2 resultVector = player.rb2d.velocity.normalized;
            resultVector += (Vector2.Perpendicular(resultVector) * Random.Range(-1f, 1f));
            resultVector = resultVector.normalized;

            GameObject tempObj = EffectFactory.SpawnEffect("DroppedFragment", this.transform.position);
            DroppedFragment tempFragment = tempObj.GetComponent<DroppedFragment>();

            int tempTotalFragments = (droppedMageFragments + droppedDragonFragments);
            bool useDragonFragment = (Random.Range(0, tempTotalFragments) < droppedDragonFragments);
            tempFragment.Setup(resultVector * droppedFragmentsSpeed, useDragonFragment);
            if (useDragonFragment) { droppedDragonFragments--; }
            else { droppedMageFragments--; }
        }
    }
}
